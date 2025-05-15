import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/ticket/models/ticket_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Storage not available

class TicketEmailService {
  // EmailJS configuration for ticket emails
  static const String serviceId = 'service_cazg1yi';
  static const String templateId = 'template_ib3l7k9'; // Text-based OTP template
  static const String htmlTemplateId = 'template_erpqfpl'; // HTML template with image support
  static const String userId = 'J5_0snPB0vsaB6jBG';
  
  // Base URL for the web app hosting the ticket viewer
  static const String ticketBaseUrl = 'https://ethiopian-railway.web.app/ticket';
  // Fallback base URL if the above is not accessible
  static const String fallbackBaseUrl = 'https://ethiopian-railway.firebaseapp.com/ticket';
  
  /// Generate a secure random token for ticket access
  static String _generateSecureToken() {
    final Random random = Random.secure();
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// Generate a shorter verification code for ticket verification
  static String _generateVerificationCode() {
    final Random random = Random.secure();
    const String chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar looking characters I, O, 0, 1
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// Store ticket data in Firestore and return ticket ID with access token
  static Future<Map<String, String>> storeTicketData(TicketModel ticket) async {
    try {
      // Generate a secure access token
      final String accessToken = _generateSecureToken();
      
      // Convert ticket to JSON
      final Map<String, dynamic> ticketJson = ticket.toJson();
      
      // Generate a unique verification code for the ticket (8 characters alphanumeric)
      final String verificationCode = _generateVerificationCode();
      
      // Add metadata fields to the ticket data
      final Map<String, dynamic> ticketData = {
        ...ticketJson,  // Spread the ticket JSON at the root level
        'accessToken': accessToken,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(days: 90)).millisecondsSinceEpoch,
        'viewed': false,
        'viewCount': 0,
        'lastViewedAt': null,
        'isVerified': false,
        'verifiedAt': null,
        'verifiedBy': null,
        'issuedAt': FieldValue.serverTimestamp(),
        'ticketCode': verificationCode,  // Add ticket verification code
      };
      
      // Store in Firestore
      final DocumentReference docRef = await FirebaseFirestore.instance
          .collection('tickets')
          .add(ticketData);
      
      // Update the document with its ID for easy reference
      await docRef.update({
        'ticketId': docRef.id,  // Add the Firestore document ID as a field
      });
      
      debugPrint('✅ Ticket stored in Firestore with ID: ${docRef.id} and verification code: $verificationCode');
      
      return {
        'ticketId': docRef.id,
        'accessToken': accessToken,
      };
    } catch (e) {
      debugPrint('❌ Error storing ticket in Firestore: $e');
      // If Firestore fails, generate a token based on ticket ID as fallback
      return {
        'ticketId': ticket.id ?? 'unknown',
        'accessToken': _generateSecureToken(),
      };
    }
  }
  
  /// Generate a ticket link that can be clicked to view the ticket
  static String generateTicketLink(String ticketId, String accessToken) {
    return '$ticketBaseUrl?id=$ticketId&token=$accessToken';
  }
  
  /// For backward compatibility with existing code
  static Future<bool> sendTicketEmail(TicketModel ticket) async {
    try {
      // Call our ticket link sender instead of the old QR method
      return await sendTicketLinkEmail(ticket);
    } catch (e) {
      debugPrint('❌ ERROR in sendTicketEmail compatibility method: $e');
      return false;
    }
  }
  
  /// Get ID requirement text based on nationality (static method that can be used in email template)
  static String _getIdRequirementText() {
    // For real implementation, this would use the passenger nationality data from the ticket
    // For demonstration, we're showing all three options as a single message
    return 'IMPORTANT: Ethiopian citizens must bring digital ID. Foreign visitors and Djibouti citizens must bring passport.';
  }

  /// Send a ticket email with a link to view the full ticket
  static Future<bool> sendTicketLinkEmail(TicketModel ticket) async {
    try {
      debugPrint('📧 Sending ticket link email to ${ticket.email}');
      
      // Show sending notification
      Get.snackbar(
        'Sending Ticket',
        'Sending your ticket link to ${ticket.email}...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Store ticket data and get access credentials
      final Map<String, String> ticketAccess = await storeTicketData(ticket);
      final String ticketId = ticketAccess['ticketId'] ?? '';
      final String accessToken = ticketAccess['accessToken'] ?? '';
      
      // Generate the ticket link
      final String ticketLink = generateTicketLink(ticketId, accessToken);
      debugPrint('🔗 Generated ticket link: $ticketLink');
      
      // Format date for email
      final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
      final timeFormatter = DateFormat('h:mm a');
      final String formattedDate = dateFormatter.format(ticket.date);
      final String formattedTime = timeFormatter.format(ticket.date);
      
      // Create an email with a link to the ticket
      final String emailContent = '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px; background-color: #f9f9f9;">
        <div style="text-align: center; background-color: #0066cc; color: white; padding: 15px; border-radius: 5px 5px 0 0;">
          <h1 style="margin: 0;">Your Ethiopian Railway Ticket</h1>
        </div>
        
        <div style="padding: 20px; background-color: white; border-radius: 0 0 5px 5px;">
          <h2 style="color: #333;">Journey Details</h2>
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee;"><strong>From:</strong></td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${ticket.departure}</td>
            </tr>
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee;"><strong>To:</strong></td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">${ticket.arrival}</td>
            </tr>
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee;"><strong>Date:</strong></td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">$formattedDate</td>
            </tr>
            <tr>
              <td style="padding: 8px; border-bottom: 1px solid #eee;"><strong>Time:</strong></td>
              <td style="padding: 8px; border-bottom: 1px solid #eee;">$formattedTime</td>
            </tr>
            <tr>
              <td style="padding: 8px;"><strong>Passenger:</strong></td>
              <td style="padding: 8px;">${ticket.firstName} ${ticket.lastName}</td>
            </tr>
          </table>
          
          <div style="text-align: center; margin: 25px 0;">
            <a href="$ticketLink" style="background-color: #0066cc; color: white; padding: 12px 25px; text-decoration: none; font-size: 16px; border-radius: 4px; display: inline-block;">
              VIEW FULL TICKET
            </a>
          </div>
          
          <p style="margin-top: 25px; font-size: 14px; color: #666;">
            Please arrive at the station at least 30 minutes before departure. You will need to present this ticket for validation at the station.
          </p>
          
          <p style="margin-top: 10px; font-size: 14px; color: #d32f2f; font-weight: bold;">
            ${_getIdRequirementText()}
          </p>
          
          <div style="border-top: 1px solid #eee; padding-top: 15px; margin-top: 25px; font-size: 12px; color: #999; text-align: center;">
            <p>You can access your ticket anytime by clicking the button above or visiting:</p>
            <p style="word-break: break-all;">$ticketLink</p>
            <p>Ticket ID: $ticketId</p>
          </div>
        </div>
      </div>
      ''';
      
      // Create EmailJS parameters
      final Map<String, dynamic> templateParams = {
        'to_email': ticket.email,
        'to_name': '${ticket.firstName} ${ticket.lastName}',
        'subject': 'Your Ethiopian Railway Ticket: ${ticket.departure} to ${ticket.arrival}',
        'otp_code': emailContent,  // Use our HTML content
        'expiration_minutes': 'Valid for your journey',
      };
      
      // Prepare the full email data package for EmailJS
      final Map<String, dynamic> emailData = {
        'service_id': serviceId, 
        'template_id': templateId,
        'user_id': userId,
        'template_params': templateParams,
      };
      
      // Send the email via EmailJS API
      debugPrint('TICKET EMAIL: Sending direct request to EmailJS');
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode(emailData),
      );
      
      // Check the EmailJS response
      debugPrint('TICKET EMAIL: Response status: ${response.statusCode}');
      debugPrint('TICKET EMAIL: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Ticket Sent!',
          'Your ticket link has been sent to ${ticket.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        throw Exception('EmailJS returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ EMAIL ERROR: $e');
      Get.snackbar(
        'Email Error',
        'Failed to send ticket link: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return false;
    }
  }
  
  /// Send verification code to the user's email for ticket verification
  static Future<bool> sendQrCodeOnly(TicketModel ticket, String qrImageBase64) async {
    try {
      debugPrint('📧 Sending verification code to ${ticket.email}');
      
      // Extract verification code from the QR data (it's base64 encoded)
      Map<String, dynamic> ticketData = {};
      try {
        // Decode the QR data to get the verification code
        final String decodedJson = utf8.decode(base64Decode(qrImageBase64));
        ticketData = jsonDecode(decodedJson);
      } catch (e) {
        debugPrint('Error extracting verification code: $e');
      }
      
      // Get the verification code or generate a fallback
      final String verificationCode = ticketData['verificationCode'] ?? 
          _generateSecureToken().substring(0, 8).toUpperCase();
      
      // Format date for the email
      final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
      final timeFormatter = DateFormat('h:mm a');
      final formattedDate = dateFormatter.format(ticket.date);
      final formattedTime = timeFormatter.format(ticket.date);
      
      // Format verification code for better readability
      final formattedCode = verificationCode.padLeft(8, '0');
      
      // Create a verification code that includes ticket details
      final String fullVerificationCode = '''
${formattedCode}

TICKET DETAILS:
Passenger: ${ticket.firstName} ${ticket.lastName}
From: ${ticket.departure}
To: ${ticket.arrival}
Date: $formattedDate
Time: $formattedTime
Seat: ${ticket.seatType}
ID: ${ticket.id}

Present this code at the station for boarding.
Station staff will verify this code.''';
      
      // Send using the OTP template that we know works
      final Map<String, dynamic> templateParams = {
        'to_email': ticket.email,
        'to_name': '${ticket.firstName} ${ticket.lastName}',
        'subject': 'ETHIOPIAN RAILWAY TICKET - ${ticket.departure} to ${ticket.arrival}',
        'otp_code': fullVerificationCode,
        'expiration_minutes': 'Valid for your journey',
      };
      
      // Use EmailJS to send the email
      final Map<String, dynamic> emailData = {
        'service_id': serviceId, 
        'template_id': templateId,
        'user_id': userId,
        'template_params': templateParams,
      };
      
      // Send the email via EmailJS API
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode(emailData),
      );
      
      // Check the response
      debugPrint('VERIFICATION EMAIL: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Also save the verification code to Firestore for staff reference
        await _saveVerificationToFirestore(ticket, verificationCode);
        return true;
      } else {
        throw Exception('EmailJS returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ VERIFICATION EMAIL ERROR: $e');
      return false;
    }
  }
  
  /// Save verification code to Firestore for staff verification
  static Future<void> _saveVerificationToFirestore(TicketModel ticket, String verificationCode) async {
    try {
      // Create verification record
      final Map<String, dynamic> verificationData = {
        'ticketId': ticket.id,
        'verificationCode': verificationCode,
        'passengerName': '${ticket.firstName} ${ticket.lastName}',
        'departure': ticket.departure,
        'arrival': ticket.arrival,
        'date': ticket.date,
        'issuedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'verifiedAt': null,
        'verifiedBy': null,
      };
      
      // Save to 'ticket_verifications' collection using verification code as ID
      await FirebaseFirestore.instance
          .collection('ticket_verifications')
          .doc(verificationCode)
          .set(verificationData);
      
      debugPrint('Verification data saved to Firebase with code: $verificationCode');
    } catch (e) {
      debugPrint('Error saving verification to Firestore: $e');
    }
  }
  
  // QR code email methods have been removed
  
  // All QR code email methods have been removed
  
  // Removed unused method
  
  /// Send a professional ticket email with proper formatting and QR code
  static Future<bool> sendProfessionalTicket(TicketModel ticket, String qrImageBase64) async {
    try {
      debugPrint('📧 Sending professional ticket email with QR to ${ticket.email}');
      
      // Show sending notification
      Get.snackbar(
        'Sending Ticket',
        'Sending your ticket to ${ticket.email}...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Format date and time nicely for the email
      final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
      final timeFormatter = DateFormat('h:mm a');
      final formattedDate = dateFormatter.format(ticket.date);
      final formattedTime = timeFormatter.format(ticket.date);
      
      // Create HTML email with embedded QR code
      final String htmlTicket = """
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
        <div style="text-align: center; padding: 10px; background-color: #047857; color: white; border-radius: 5px 5px 0 0;">
          <h1 style="margin: 0; font-size: 24px;">🎟️ ETHIOPIAN RAILWAY TICKET 🎟️</h1>
        </div>
        
        <div style="padding: 20px;">
          <div style="text-align: center; margin-bottom: 20px;">
            <img src="data:image/png;base64,${qrImageBase64}" alt="QR Code" style="width: 200px; height: 200px;">
            <p style="font-size: 14px; color: #666; margin-top: 5px;">Scan this QR code at the station</p>
          </div>
          
          <div style="border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 10px;">
            <h2 style="margin: 0; color: #333; font-size: 18px;">TICKET #: ${ticket.id}</h2>
          </div>
          
          <div style="margin-bottom: 20px;">
            <h3 style="color: #047857; margin-bottom: 10px; font-size: 16px;">📍 JOURNEY DETAILS</h3>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 5px 0; color: #666;">FROM:</td>
                <td style="padding: 5px 0; font-weight: bold;">${ticket.departure}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0; color: #666;">TO:</td>
                <td style="padding: 5px 0; font-weight: bold;">${ticket.arrival}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0; color: #666;">DATE:</td>
                <td style="padding: 5px 0; font-weight: bold;">${formattedDate}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0; color: #666;">TIME:</td>
                <td style="padding: 5px 0; font-weight: bold;">${formattedTime}</td>
              </tr>
            </table>
          </div>
          
          <div style="margin-bottom: 20px;">
            <h3 style="color: #047857; margin-bottom: 10px; font-size: 16px;">👤 PASSENGER INFORMATION</h3>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 5px 0; color: #666;">NAME:</td>
                <td style="padding: 5px 0; font-weight: bold;">${ticket.firstName} ${ticket.lastName}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0; color: #666;">PHONE:</td>
                <td style="padding: 5px 0;">${ticket.phone}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0; color: #666;">EMAIL:</td>
                <td style="padding: 5px 0;">${ticket.email}</td>
              </tr>
            </table>
          </div>
          
          <div style="margin-bottom: 20px;">
            <h3 style="color: #047857; margin-bottom: 10px; font-size: 16px;">💺 SEAT INFORMATION</h3>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 5px 0; color: #666;">TYPE:</td>
                <td style="padding: 5px 0; font-weight: bold;">${ticket.seatType}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0; color: #666;">PRICE:</td>
                <td style="padding: 5px 0; font-weight: bold;">ETB ${ticket.price.toStringAsFixed(2)}</td>
              </tr>
            </table>
          </div>
          
          <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
            <h3 style="color: #047857; margin-bottom: 10px; font-size: 16px;">IMPORTANT INSTRUCTIONS</h3>
            <ul style="padding-left: 20px; margin: 0;">
              <li style="margin-bottom: 5px;">Please arrive at the station 30 minutes before departure</li>
              <li style="margin-bottom: 5px;">Show this QR code to the staff for validation</li>
              <li style="margin-bottom: 5px; font-weight: bold; color: #e63946;">${_getIdRequirementText()}</li>
              <li style="margin-bottom: 5px;">Baggage allowance: 20kg per passenger</li>
            </ul>
          </div>
        </div>
        
        <div style="text-align: center; padding: 10px; background-color: #f5f5f5; border-radius: 0 0 5px 5px; color: #666; font-size: 14px;">
          <p style="margin: 0;">Ethiopian Railway wishes you a pleasant journey!</p>
          <p style="margin: 5px 0 0;">© ${DateTime.now().year} Ethiopian Railway Corporation. All rights reserved.</p>
        </div>
      </div>
      """;
      
      // Create a plain text fallback for email clients that don't support HTML
      final String plainTextTicket = 
          '🎟️ ETHIOPIAN RAILWAY TICKET 🎟️\n\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
          'TICKET #: ${ticket.id}\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n'
          '📍 JOURNEY DETAILS:\n'
          '   FROM: ${ticket.departure}\n'
          '   TO: ${ticket.arrival}\n'
          '   DATE: $formattedDate\n'
          '   TIME: $formattedTime\n\n'
          '👤 PASSENGER INFORMATION:\n'
          '   NAME: ${ticket.firstName} ${ticket.lastName}\n'
          '   PHONE: ${ticket.phone}\n'
          '   EMAIL: ${ticket.email}\n\n'
          '💺 SEAT INFORMATION:\n'
          '   TYPE: ${ticket.seatType}\n'
          '   PRICE: ETB ${ticket.price.toStringAsFixed(2)}\n\n'
          '✅ Please arrive at the station 30 minutes before departure\n'
          '✅ A QR code is attached for validation at the station\n'
          '✅ This ticket is valid only for the specified date and time\n\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
          'Ethiopian Railway wishes you a pleasant journey!\n'
          '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
      
      // Create EmailJS parameters with HTML content
      final Map<String, dynamic> templateParams = {
        'to_email': ticket.email,
        'to_name': '${ticket.firstName} ${ticket.lastName}',
        'subject': 'Your Ethiopian Railway Ticket: ${ticket.departure} to ${ticket.arrival}',
        'otp_code': plainTextTicket, // Fallback plain text version
        'html_content': htmlTicket, // HTML version with embedded QR code
        'expiration_minutes': 'Valid for your journey',
      };
      
      // Prepare the full email data package for EmailJS
      final Map<String, dynamic> emailData = {
        'service_id': serviceId, 
        'template_id': templateId,
        'user_id': userId,
        'template_params': templateParams,
      };
      
      // Send the email via EmailJS API
      debugPrint('TICKET EMAIL: Sending direct request to EmailJS');
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode(emailData),
      );
      
      // Check the EmailJS response
      debugPrint('TICKET EMAIL: Response status: ${response.statusCode}');
      debugPrint('TICKET EMAIL: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Ticket Sent!',
          'Your ticket with QR code has been sent to ${ticket.email}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        throw Exception('EmailJS returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ EMAIL ERROR: $e');
      Get.snackbar(
        'Email Error',
        'Failed to send ticket: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return false;
    }
  }
}

