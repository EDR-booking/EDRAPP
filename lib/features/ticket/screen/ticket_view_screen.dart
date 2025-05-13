// Removed unused imports
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/services/qr_generator_service.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class TicketViewScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketViewScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('E-Ticket', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              Get.snackbar(
                'Coming Soon',
                'Ticket sharing will be available in the next update',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: QRGeneratorService.generateQRData(
          ticket.id ?? 'unknown',
          ticket.firstName,
          ticket.lastName,
          ticket.departure,
          ticket.arrival,
          ticket.date,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating secure ticket...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error generating ticket: ${snapshot.error}'),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else {
            final String qrData = snapshot.data ?? '';
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Ticket Card
                  _buildTicketCard(context, qrData),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () => _showEmailMessage(),
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.download_outlined,
                        label: 'Download',
                        onTap: () {
                          Get.snackbar(
                            'Coming Soon',
                            'Ticket download will be available in the next update',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions Card
                  _buildInstructionsCard(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Show message when email button is clicked
  void _showEmailMessage() {
    Get.dialog(
      AlertDialog(
        title: Text('Send Ticket to Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your ticket will be sent to: ${ticket.email}'),
            SizedBox(height: 20),
            Text('Would you like to receive:'),
            CheckboxListTile(
              title: Text('QR Code only'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('Full ticket details'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Email Sent',
                'Your ticket has been sent to ${ticket.email}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, String qrData) {
    // Format date for display
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final String formattedDate = dateFormatter.format(ticket.date);
    final String formattedTime = timeFormatter.format(ticket.date);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ticket Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: TColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'ETHIOPIAN RAILWAY',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'E-TICKET',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          
          // Ticket ID
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade200,
            child: Center(
              child: Text(
                'TICKET #: ${ticket.id}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Journey Section
                Text(
                  'JOURNEY DETAILS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(context, 'From', ticket.departure),
                _buildDetailRow(context, 'To', ticket.arrival),
                _buildDetailRow(context, 'Date', formattedDate),
                _buildDetailRow(context, 'Time', formattedTime),
                
                const SizedBox(height: 16),
                
                // Passenger Section
                Text(
                  'PASSENGER INFORMATION',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context, 
                  'Name', 
                  '${ticket.firstName} ${ticket.lastName}',
                ),
                _buildDetailRow(context, 'Phone', ticket.phone),
                _buildDetailRow(context, 'Email', ticket.email),
                
                const SizedBox(height: 16),
                
                // Seat Section
                Text(
                  'SEAT INFORMATION',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(context, 'Type', ticket.seatType),
                _buildDetailRow(
                  context, 
                  'Price', 
                  'ETB ${ticket.price.toStringAsFixed(2)}',
                ),
                
                const SizedBox(height: 24),
                
                // QR Code
                Center(
                  child: Column(
                    children: [
                      Text(
                        'SCAN AT THE STATION',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QRGeneratorService.generateQRCodeWidget(
                          qrData,
                          size: 180,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.id ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL PRICE',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
                Text(
                  'ETB ${ticket.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: TColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IMPORTANT INSTRUCTIONS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInstructionItem(
              context,
              icon: Icons.access_time,
              text: 'Please arrive at the station at least 30 minutes before departure',
            ),
            _buildInstructionItem(
              context,
              icon: Icons.qr_code_scanner,
              text: 'Show this QR code to the staff for verification',
            ),
            // ID requirement based on nationality
            _buildInstructionItem(
              context,
              icon: Icons.credit_card,
              text: _getIdRequirementText(),
              isHighlighted: true,
            ),
            _buildInstructionItem(
              context,
              icon: Icons.luggage,
              text: 'Baggage allowance: 20kg per passenger',
            ),
          ],
        ),
      ),
    );
  }

  // Get ID requirement text based on nationality (currently hardcoded, but could be based on ticket data)
  String _getIdRequirementText() {
    // For real implementation, this would use the passenger nationality data from the ticket
    // For demonstration, we're showing all three options as a single message
    return 'IMPORTANT: Ethiopian citizens must bring digital ID. Foreign visitors and Djibouti citizens must bring passport.';
  }

  Widget _buildInstructionItem(BuildContext context, {
    required IconData icon,
    required String text,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isHighlighted ? Colors.red : Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isHighlighted ? Colors.red : Colors.black87,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
