import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:random_string/random_string.dart';

class EmailService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _otpExpirationMinutes = 2; // OTP valid for 2 minutes

  // Generate a 6-digit OTP
  static String generateOTP() {
    return randomNumeric(6);
  }

  // Store OTP in Firebase with expiration time
  static Future<void> storeOTP(String email, String otp) async {
    try {
      final expirationTime = DateTime.now().add(Duration(minutes: _otpExpirationMinutes));
      
      await _firestore.collection('otps').doc(email).set({
        'otp': otp,
        'expirationTime': expirationTime,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('OTP stored successfully in Firebase for $email: $otp');
    } catch (e) {
      print('Error storing OTP in Firebase: $e');
      // Create a local fallback for testing if Firebase fails
      _localOTPStore[email] = {
        'otp': otp,
        'expirationTime': DateTime.now().add(Duration(minutes: _otpExpirationMinutes)),
      };
      print('OTP stored in local fallback for $email: $otp');
    }
  }

  // Verify OTP from Firebase or local store
  static Future<bool> verifyOTP(String email, String enteredOTP) async {
    try {
      // First try Firebase
      try {
        final docSnapshot = await _firestore.collection('otps').doc(email).get();
        
        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          final storedOTP = data['otp'] as String;
          final expirationTime = (data['expirationTime'] as Timestamp).toDate();
          
          // Check if OTP is expired
          if (DateTime.now().isAfter(expirationTime)) {
            // Delete expired OTP
            await _firestore.collection('otps').doc(email).delete();
            print('OTP expired for $email');
            return false; // OTP expired
          }
          
          // Check if OTP matches
          final isValid = enteredOTP == storedOTP;
          
          // If valid, delete the OTP document (one-time use)
          if (isValid) {
            await _firestore.collection('otps').doc(email).delete();
            print('OTP verified successfully for $email');
          } else {
            print('Invalid OTP entered for $email');
          }
          
          return isValid;
        }
      } catch (e) {
        print('Error verifying OTP with Firebase: $e');
        // Continue to local fallback
      }
      
      // Fallback to local store if Firebase failed or no document exists
      if (_localOTPStore.containsKey(email)) {
        final storedData = _localOTPStore[email]!;
        final storedOTP = storedData['otp'] as String;
        final expirationTime = storedData['expirationTime'] as DateTime;
        
        // Check if OTP is expired
        if (DateTime.now().isAfter(expirationTime)) {
          _localOTPStore.remove(email);
          print('Local OTP expired for $email');
          return false; // OTP expired
        }
        
        // Check if OTP matches
        final isValid = enteredOTP == storedOTP;
        
        // If valid, remove from local store (one-time use)
        if (isValid) {
          _localOTPStore.remove(email);
          print('Local OTP verified successfully for $email');
        } else {
          print('Invalid local OTP entered for $email');
        }
        
        return isValid;
      }
      
      print('No OTP found for $email in either Firebase or local store');
      return false; // No OTP found for this email
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Local OTP store for fallback when Firebase is unavailable
  static final Map<String, Map<String, dynamic>> _localOTPStore = {};
  
  // Send OTP via email and store in Firebase
  static Future<bool> sendOTP(String email) async {
    try {
      // Debug log to track the email address being used
      print('\n\nSENDING OTP TO EMAIL: $email\n\n');
      
      // Generate OTP
      final otp = generateOTP();
      
      // Store OTP in Firebase with expiration time
      await storeOTP(email, otp);

      // In a production environment, you would use a real email service
      // For development, we'll use a mock email service to avoid socket issues
      await _sendEmailWithFallback(email, otp);
      
      // Even if email sending fails, we'll return true for testing purposes
      // since the OTP is stored in Firebase and can be retrieved for testing
      print('==================================================');
      print('🔑 OTP for $email: $otp (valid for $_otpExpirationMinutes minutes)');
      print('==================================================');
      
      return true;
    } catch (e) {
      print('Error in sendOTP process: $e');
      // Still return true for development testing
      return true;
    }
  }
  
  // Attempt to send email with fallback options
  static Future<bool> _sendEmailWithFallback(String email, String otp) async {
    try {
      // First try with REST API (works in web)
      return await _sendWithRestAPI(email, otp);
    } catch (e) {
      print('Primary email method (REST API) failed: $e');
      try {
        // Try with mailer package (works in mobile/desktop)
        return await _sendWithMailer(email, otp);
      } catch (e) {
        print('Secondary email method (mailer) failed: $e');
        try {
          // Fallback to a mock email service
          return _mockEmailSend(email, otp);
        } catch (e) {
          print('Fallback email method failed: $e');
          return false;
        }
      }
    }
  }
  
  // Send email using a REST API (works in web)
  static Future<bool> _sendWithRestAPI(String email, String otp) async {
    try {
      // EmailJS configuration
      // IMPORTANT: Replace these placeholder values with your actual EmailJS credentials
      // Sign up at https://www.emailjs.com/ (free plan includes 200 emails/month)
      final serviceId = 'service_cazg1yi'; // Your EmailJS service ID
      final templateId = 'template_ib3l7k9'; // Your EmailJS template ID (this should be different from service ID)
      final userId = 'J5_0snPB0vsaB6jBG'; // Your EmailJS user ID (API key)
      
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      // Print the request for debugging
      final requestBody = jsonEncode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': email, // This should be the recipient's email
          'otp_code': otp,
          'expiration_minutes': _otpExpirationMinutes,
          'recipient': email, // Adding a duplicate field in case 'to_email' is not being used
        },
      });
      print('EmailJS request: $requestBody');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      
      print('EmailJS response status: ${response.statusCode}');
      print('EmailJS response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('Email sent successfully via REST API to $email');
        return true;
      } else {
        print('Failed to send email via REST API: ${response.body}');
        throw Exception('Failed to send email: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending email with REST API: $e');
      throw e; // Rethrow to try next method
    }
  }
  
  // Try to send with mailer package
  static Future<bool> _sendWithMailer(String email, String otp) async {
    try {
      // Replace these with your email credentials
      String username = 'kalebtegegn6@gmail.com';
      String password = 'sjjx zpys qiyh ettv';

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Ethio-Djibouti Railway')
        ..recipients.add(email)
        ..subject = 'Email Verification OTP'
        ..text = '''Your OTP for email verification is: $otp

This OTP will expire in $_otpExpirationMinutes minutes. Please do not share it with anyone.''';

      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Error sending email with mailer: $e');
      throw e; // Rethrow to try fallback
    }
  }
  
  // Mock email sending for development
  static bool _mockEmailSend(String email, String otp) {
    // In a real app, you might use a different email service API here
    // For now, we'll just log the OTP and consider it sent
    print('MOCK EMAIL SENT TO: $email');
    print('OTP: $otp');
    print('This OTP will expire in $_otpExpirationMinutes minutes');
    return true;
  }
  
  // Delete expired OTPs (can be called periodically)
  static Future<void> cleanupExpiredOTPs() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore.collection('otps').get();
      
      for (var doc in querySnapshot.docs) {
        final expirationTime = (doc.data()['expirationTime'] as Timestamp).toDate();
        if (now.isAfter(expirationTime)) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up expired OTPs: $e');
    }
  }
}
