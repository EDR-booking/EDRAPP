import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// A streamlined service for sending ticket emails
/// This simplified version only sends the ticket number without additional text
class TicketEmailService {
  // EmailJS service credentials
  static const String serviceId = 'service_o7qw1pu';
  static const String userId = 'mQUT9kMHvq4MsNT1m';

  /// Send just the ticket number to the user's email
  /// Returns true if email sent successfully, false otherwise
  static Future<bool> sendTicketEmail(TicketModel ticket) async {
    try {
      debugPrint('📧 Sending minimal ticket email to ${ticket.email}');
      
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
        return false;
      }

      // Create a custom EmailJS template using an email template we know works
      final emailParams = {
        'service_id': serviceId,
        'template_id': 'template_8clncxo', // Simple template with minimal text
        'user_id': userId,
        'template_params': {
          'to_email': ticket.email,
          'subject': 'Ethiopian Railway Ticket',
          'message': ticket.ticket_number,
        },
      };

      // Send the email via EmailJS
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode(emailParams),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully');
        
        // Success notification
        Get.snackbar(
          'Email Sent',
          'Ticket sent to ${ticket.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        return true;
      } else {
        debugPrint('❌ Failed to send email: ${response.body}');
        
        // Error notification
        Get.snackbar(
          'Email Error',
          'Failed to send ticket. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception sending email: $e');
      
      // Exception notification
      Get.snackbar(
        'Email Error',
        'An error occurred while sending the ticket',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return false;
    }
  }
}
