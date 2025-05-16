// Imports
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add import for Clipboard
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:flutter_application_2/features/ticket/services/qr_generator_service.dart';
import 'package:flutter_application_2/features/ticket/services/ticket_email_service.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class TicketViewScreen extends StatefulWidget {
  final TicketModel ticket;
  final bool isNewBooking;

  const TicketViewScreen({Key? key, required this.ticket, this.isNewBooking = false}) : super(key: key);
  
  @override
  State<TicketViewScreen> createState() => _TicketViewScreenState();
}

class _TicketViewScreenState extends State<TicketViewScreen> {
  // Track if button is disabled
  bool _emailButtonDisabled = false;
  
  // Getter for ticket to match previous code
  TicketModel get ticket => widget.ticket;

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
          ticket.ticket_number ?? ticket.id ?? 'unknown',
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
                      // Only show email button for new bookings
                      if (widget.isNewBooking)
                        _buildActionButton(
                          context,
                          icon: Icons.email_outlined,
                          label: _emailButtonDisabled ? 'Sending...' : 'Send Email',
                          onTap: _emailButtonDisabled ? null : () => _sendEmailWithTicketId(),
                          isDisabled: _emailButtonDisabled,
                        ),
                      _buildActionButton(
                        context,
                        icon: Icons.download_outlined,
                        label: 'Download',
                        onTap: () => _downloadTicket(),
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
  
  // Build action button with icon and label
  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap, // This will be null when disabled
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled 
            ? Colors.grey.withOpacity(0.2)  // Grayed out when disabled
            : TColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, 
              color: isDisabled ? Colors.grey : TColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDisabled ? Colors.grey : TColors.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // A completely simplified version of sending ticket by email
  void _sendEmailWithTicketId() {
    // Set button as disabled temporarily
    setState(() {
      _emailButtonDisabled = true;
    });
    
    // Show a simple snackbar that we're sending
    Get.snackbar(
      'Sending Email',
      'Sending ticket to ${ticket.email}...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
    
    // Fire-and-forget approach to send the email
    TicketEmailService.sendTicketEmail(ticket).then((success) {
      // Show appropriate message based on success
      if (success) {
        Get.snackbar(
          'Email Sent',
          'Ticket sent to ${ticket.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Email Error',
          'Could not send email. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }).catchError((error) {
      // Handle any errors
      Get.snackbar(
        'Error',
        'Failed to send email: $error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }).whenComplete(() {
      // Always re-enable the button
      if (mounted) {
        setState(() {
          _emailButtonDisabled = false;
        });
      }
    });
  }
  
  // Download QR code as an image
  void _downloadTicket() async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // Generate QR code data
      final qrData = ticket.ticket_number ?? ticket.id ?? 'Unknown ticket';
      
      // Create a QR image
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );
      
      // Convert to image - size 200x200 pixels
      final size = 200.0;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Fill with white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = Colors.white,
      );
      
      // Draw QR code
      qrPainter.paint(canvas, Size(size, size));
      
      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to generate QR image');
      }
      
      final bytes = byteData.buffer.asUint8List();
      
      // Save the image using ImageGallerySaver
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'Ethiopian_Railway_Ticket_${ticket.ticket_number}_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Check if saved successfully
      if (result['isSuccess']) {
        Get.snackbar(
          'Success',
          'QR code saved to your gallery',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        throw Exception('Failed to save image to gallery');
      }
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Show error message
      Get.snackbar(
        'Error',
        'Could not download QR code: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }
  
  // Show dialog with copyable ticket number if email fails
  void _showCopyableTicketId() {
    // Close loading dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    
    // Show dialog with copyable ticket number
    Get.dialog(
      AlertDialog(
        title: Text('Your Ticket Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Could not open email app. Copy your ticket number:'),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              child: SelectableText(
                '${ticket.ticket_number ?? 'N/A'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    // Determine if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
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
                    color: textColor,
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
            // Instruction for using the ticket number in My Ticket tab
            _buildInstructionItem(
              context,
              icon: Icons.confirmation_number,
              text: 'Use your ticket number "${ticket.ticket_number}" in the "My Ticket" tab to access your ticket at any time',
              isHighlighted: true,
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
    // Determine if we're in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? 
      (isHighlighted ? Colors.red[300] : Colors.white) : 
      (isHighlighted ? Colors.red : Colors.black87);
    
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
                    color: textColor,
                    fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
