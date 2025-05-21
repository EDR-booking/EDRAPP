import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';

/// Service for sending ticket emails using Supabase Edge Functions
class TicketEmailService {
  static final TicketEmailService _instance = TicketEmailService._internal();
  final _supabase = Supabase.instance.client;
  
  factory TicketEmailService() {
    return _instance;
  }
  
  TicketEmailService._internal();
  
  /// Send ticket email with the ticket number using Supabase Edge Function
  /// Returns true if email sent successfully, false otherwise
  Future<bool> sendTicketEmail(TicketModel ticket) async {
    try {
      debugPrint('📧 Sending ticket email to ${ticket.email}');
      
      // Show sending notification
      Get.snackbar(
        'Sending Ticket',
        'Sending your ticket to ${ticket.email}...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Ensure we have a ticket number
      if (ticket.ticket_number == null || ticket.ticket_number!.isEmpty) {
        debugPrint('❌ Error: No ticket number available');
        _showErrorSnackbar('No ticket number available');
        return false;
      }

      // Call the Supabase Edge Function to send the email
      final response = await _supabase.functions.invoke('send-ticket-email', body: {
        'email': ticket.email,
        'ticketNumber': ticket.ticket_number!,
        'passengerName': '${ticket.firstName} ${ticket.lastName}'.trim(),
      });

      if (response.status == 200) {
        debugPrint('✅ Email sent successfully');
        
        // Success notification
        Get.snackbar(
          'Email Sent',
          'Your ticket has been sent to ${ticket.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] ?? 'Failed to send email';
        debugPrint('❌ Failed to send email: $errorMessage');
        _showErrorSnackbar(errorMessage);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending email: $e');
      _showErrorSnackbar('An error occurred while sending the email');
      return false;
    }
  }
  
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Email Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
