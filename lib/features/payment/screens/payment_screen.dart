import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_2/features/payment/controllers/payment_controller.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/screen/ticket_view_screen.dart';
import 'package:flutter_application_2/features/payment/screens/payment_webview_screen.dart';
import 'package:flutter_application_2/features/payment/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final TicketModel ticket;
  
  const PaymentScreen({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Initialize controller
  final PaymentController _paymentController = Get.put(PaymentController());
  
  @override
  void initState() {
    super.initState();
    // Reset payment state when screen is loaded
    _paymentController.resetPaymentState();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment for Ticket ${widget.ticket.ticket_number}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Get.back(),
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        // Show loading spinner during processing
        if (_paymentController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Processing payment...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Show payment completed success page
        if (_paymentController.isPaymentCompleted.value) {
          return _buildPaymentCompletedScreen();
        }
        
        // Show payment checkout page if initialized
        if (_paymentController.isPaymentInitialized.value) {
          return _buildPaymentCheckoutScreen();
        }
        
        // Show main payment options page
        return _buildPaymentOptionsScreen();
      }),
    );
  }
  
  // Default payment options screen 
  Widget _buildPaymentOptionsScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
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
          
          const SizedBox(height: 24),
          
          // Payment options title
          Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Payment options cards
          // Demo Card Payment
          _buildPaymentMethodCard(
            title: 'Card Payment',
            icon: Icons.credit_card,
            description: 'Pay with credit or debit card',
            color: Colors.blue,
            onTap: () => _initializePayment('card'),
          ),
          
          const SizedBox(height: 12),
          
          // Demo Mobile Money
          _buildPaymentMethodCard(
            title: 'Mobile Money',
            icon: Icons.phone_android,
            description: 'Pay with your mobile wallet',
            color: Colors.green,
            onTap: () => _initializePayment('mobile_money'),
          ),
          
          const SizedBox(height: 12),
          
          // Demo Pay on Arrival (only for Ethiopian citizens)
          if (widget.ticket.citizenship == 'Ethiopian')
            _buildPaymentMethodCard(
              title: 'Pay on Arrival',
              icon: Icons.money,
              description: 'Pay at the station before departure',
              color: Colors.amber,
              onTap: _handlePayOnArrival,
            ),
            
          // Error message if any
          if (_paymentController.paymentError.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                _paymentController.paymentError.value,
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Payment checkout screen with redirect button
  Widget _buildPaymentCheckoutScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_checkout,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to Complete Your Payment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You will be redirected to a secure payment page. After completing payment, you\'ll be returned to this app.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openPaymentPage,
              icon: const Icon(Icons.open_in_new),
              label: const Text(
                'Go to Payment Page',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _checkPaymentStatus,
              child: Text(
                'I\'ve completed payment',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _paymentController.resetPaymentState(),
              child: Text(
                'Cancel payment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Payment completed success screen
  Widget _buildPaymentCompletedScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your ticket has been confirmed. You can view your ticket details below.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (_paymentController.currentPaymentStatus.value?.reference != null) ...[
              const SizedBox(height: 16),
              Text(
                'Reference: ${_paymentController.currentPaymentStatus.value?.reference}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _viewTicket,
              icon: const Icon(Icons.confirmation_number),
              label: const Text(
                'View My Ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper widgets
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
  
  Widget _buildPaymentMethodCard({
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  // Payment actions - Using the original WebView implementation with Supabase Edge Functions
  Future<void> _initializePayment(String method) async {
    try {
      setState(() => _paymentController.isLoading.value = true);
      
      // Generate a unique payment ID based on the ticket number
      final paymentId = 'EDR-TICKET-${widget.ticket.ticket_number}-${DateTime.now().millisecondsSinceEpoch}';
      
      // Update ticket with payment ID
      if (widget.ticket.id != null) {
        final updatedTicket = widget.ticket.copyWith(
          paymentId: paymentId,
          paymentStatus: 'processing'
        );
        await _paymentController.updateTicketPaymentDetails(widget.ticket.id!, updatedTicket);
      }
      
      // Get the HTML content from Supabase Edge Function
      final paymentService = PaymentService();
      final htmlContent = await paymentService.initializePaymentWithChapa(
        ticket: widget.ticket,
        returnUrl: 'edrapp://payment-callback',
      );
      
      setState(() => _paymentController.isLoading.value = false);
      
      if (htmlContent != null && htmlContent.isNotEmpty) {
        // Navigate to WebView screen with the HTML content
        Get.to(() => PaymentWebViewScreen(
          htmlContent: htmlContent,
          ticket: widget.ticket,
          paymentId: paymentId,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize Chapa payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _paymentController.isLoading.value = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Check payment status manually after external browser payment
  Future<void> _checkPaymentStatusManually(String txRef, String ticketId) async {
    try {
      setState(() => _paymentController.isLoading.value = true);
      
      final success = await _paymentController.checkPaymentStatus(txRef, ticketId);
      
      setState(() => _paymentController.isLoading.value = false);
      
      if (success) {
        // If payment was successful, show success and navigate to ticket view
        Get.offAll(() => TicketViewScreen(
          ticket: widget.ticket.copyWith(
            status: 'confirmed',
            paymentStatus: 'completed',
          ), 
          isNewBooking: true,
        ));
      } else {
        // Payment still pending or failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment status: ${_paymentController.currentPaymentStatus.value?.status ?? 'pending'}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _paymentController.isLoading.value = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _openPaymentPage() async {
    final opened = await _paymentController.openCheckoutUrl();
    
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open payment page: ${_paymentController.paymentError.value}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _checkPaymentStatus() async {
    if (_paymentController.paymentResponse.value?.paymentId == null) {
      return;
    }
    
    final success = await _paymentController.checkPaymentStatus(
      _paymentController.paymentResponse.value!.paymentId!,
      widget.ticket.id ?? '',
    );
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verification failed: ${_paymentController.paymentError.value}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _handlePayOnArrival() async {
    // Update the ticket to have pending payment status
    final success = await _paymentController.completePaymentDemo(widget.ticket);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process payment: ${_paymentController.paymentError.value}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _viewTicket() {
    // Navigate to ticket view screen
    Get.off(() => TicketViewScreen(ticket: widget.ticket, isNewBooking: false));
  }
}
