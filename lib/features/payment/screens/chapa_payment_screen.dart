import 'package:chapasdk/chapasdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_2/constants/chapa_constants.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/controllers/ticketController.dart';
import 'package:flutter_application_2/features/ticket/screen/ticket_view_screen.dart';

class ChapaPaymentScreen extends StatefulWidget {
  final TicketModel ticket;
  final Function() onPaymentCancelled;
  
  const ChapaPaymentScreen({
    Key? key,
    required this.ticket,
    required this.onPaymentCancelled,
  }) : super(key: key);

  @override
  State<ChapaPaymentScreen> createState() => _ChapaPaymentScreenState();
}

class _ChapaPaymentScreenState extends State<ChapaPaymentScreen> {
  final TicketController _ticketController = Get.find<TicketController>();
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      onWillPop: () async {
        widget.onPaymentCancelled();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Payment for Ticket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => widget.onPaymentCancelled(),
          ),
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Payment header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('From', widget.ticket.departure),
                    _buildInfoRow('To', widget.ticket.arrival),
                    _buildInfoRow('Date', _formatDate(widget.ticket.date)),
                    _buildInfoRow('Passenger', '${widget.ticket.firstName} ${widget.ticket.lastName}'),
                    _buildInfoRow('Seat Type', widget.ticket.seatType),
                    if (widget.ticket.bedPosition.isNotEmpty)
                      _buildInfoRow('Position', widget.ticket.bedPosition),
                    const Divider(height: 32),
                    _buildInfoRow(
                      'Total Amount', 
                      'ETB ${widget.ticket.price.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Payment button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel button
              TextButton(
                onPressed: widget.onPaymentCancelled,
                child: Text(
                  'Cancel Payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _processPayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Generate a unique transaction reference
      final txRef = 'EDR-${widget.ticket.ticket_number}-${DateTime.now().millisecondsSinceEpoch}';
      
      await Chapa.paymentParameters(
        context: context,
        publicKey: ChapaConstants.chapaPublicKey,
        currency: ChapaConstants.defaultCurrency,
        amount: widget.ticket.price.toString(),
        email: widget.ticket.email,
        phone: widget.ticket.phone,
        firstName: widget.ticket.firstName,
        lastName: widget.ticket.lastName,
        txRef: txRef,
        title: 'EDR Ticket Purchase',
        desc: 'Payment for ticket from ${widget.ticket.departure} to ${widget.ticket.arrival}',
        namedRouteFallBack: '',
        nativeCheckout: true,
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: ChapaConstants.paymentMethods,
        onPaymentFinished: (message, reference, amount) {
          // Handle payment result
          if (message == 'paymentSuccessful') {
            // Payment was successful
            _handleSuccessfulPayment(reference);
          } else {
            // Payment was cancelled or failed
            widget.onPaymentCancelled();
          }
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment processing error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  Future<void> _handleSuccessfulPayment(String reference) async {
    try {
      // Update ticket with payment reference
      final updatedTicket = widget.ticket.copyWith(
        paymentReference: reference,
        paymentStatus: 'completed',
        status: 'confirmed',
      );
      
      // Save the ticket to Firestore
      final ticketId = await _ticketController.saveTicketAfterPayment(updatedTicket);
      
      if (ticketId.isEmpty) {
        throw Exception('Failed to save ticket after payment');
      }
      
      // Send confirmation email
      final emailSent = await _ticketController.sendTicketEmail(updatedTicket);
      
      // Navigate to ticket view
      Get.offAll(() => TicketViewScreen(
        ticket: updatedTicket,
        isNewBooking: true,
      ));
      
      if (!emailSent) {
        // Show warning if email failed to send
        Get.snackbar(
          'Ticket Booked', 
          'Your ticket was booked but we couldn\'t send the confirmation email. Please check your email address.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error finalizing ticket: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      // Return to payment screen on error
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
