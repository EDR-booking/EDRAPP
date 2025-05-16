// Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/services/qr_generator_service.dart';
import 'package:flutter_application_2/features/ticket/services/ticket_email_service.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

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
                  
                  // Actions row with email and download buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Send Email',
                        onTap: () => _sendEmailWithTicketNumber(),
                      ),
                      _buildActionButton(
                        context,
                        icon: Icons.download_outlined,
                        label: 'Download',
                        onTap: () => _downloadQRCode(qrData),
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
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'E-TICKET',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),

          // Ticket Number
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: TColors.primary.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number, color: TColors.primary),
                const SizedBox(width: 8),
                Text(
                  'TICKET #: ${ticket.ticket_number ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
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
                      ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(context, 'Date', formattedDate),
                _buildDetailRow(context, 'Time', formattedTime),
                _buildDetailRow(
                  context, 
                  'From', 
                  ticket.departure,
                ),
                _buildDetailRow(
                  context, 
                  'To', 
                  ticket.arrival,
                ),
                
                const SizedBox(height: 16),
                
                // Passenger Section
                Text(
                  'PASSENGER DETAILS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
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
                      ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context, 
                  'Seat Type', 
                  ticket.seatType,
                ),
                _buildDetailRow(
                  context, 
                  'Bed Position', 
                  ticket.bedPosition,
                ),
                _buildDetailRow(
                  context, 
                  'Status', 
                  ticket.status,
                ),
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ticket Number: ${ticket.ticket_number ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                    color: isHighlighted ? Colors.red : (isDarkMode ? Colors.white : Colors.black87),
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build action buttons
  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // Method to send ticket information via email
  void _sendEmailWithTicketNumber() async {
    try {
      await TicketEmailService().sendTicketLinkEmail(ticket);
      Get.snackbar(
        'Success',
        'Ticket information sent to ${ticket.email}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send email: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Method to download QR code as image
  void _downloadQRCode(String qrData) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to save the QR code',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Generate QR code image bytes
      final qrImageBytes = await QRGeneratorService.generateQRImageBytes(qrData, size: 300);
      
      if (qrImageBytes != null) {
        // Save the image to gallery
        final result = await ImageGallerySaver.saveImage(
          qrImageBytes,
          quality: 100,
          name: 'edr_ticket_${ticket.ticket_number ?? 'unknown'}',
        );
        
        // Close loading dialog
        Get.back();
        
        // Show success message
        Get.snackbar(
          'Success',
          'QR code saved to gallery',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Close loading dialog
        Get.back();
        
        throw Exception('Failed to generate QR code image');
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Failed to save QR code: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
