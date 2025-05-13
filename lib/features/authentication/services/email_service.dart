import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final expirationTime = DateTime.now().add(Duration(minutes: _otpExpirationMinutes));
    
    await _firestore.collection('otps').doc(email).set({
      'otp': otp,
      'expirationTime': expirationTime,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Verify OTP from Firebase
  static Future<bool> verifyOTP(String email, String enteredOTP) async {
    try {
      final docSnapshot = await _firestore.collection('otps').doc(email).get();
      
      if (!docSnapshot.exists) {
        return false; // No OTP found for this email
      }
      
      final data = docSnapshot.data()!;
      final storedOTP = data['otp'] as String;
      final expirationTime = (data['expirationTime'] as Timestamp).toDate();
      
      // Check if OTP is expired
      if (DateTime.now().isAfter(expirationTime)) {
        // Delete expired OTP
        await _firestore.collection('otps').doc(email).delete();
        return false; // OTP expired
      }
      
      // Check if OTP matches
      final isValid = enteredOTP == storedOTP;
      
      // If valid, delete the OTP document (one-time use)
      if (isValid) {
        await _firestore.collection('otps').doc(email).delete();
      }
      
      return isValid;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Send OTP via email and store in Firebase
  static Future<bool> sendOTP(String email) async {
    try {
      // Generate OTP
      final otp = generateOTP();
      
      // Store OTP in Firebase with expiration time
      await storeOTP(email, otp);

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
      print('Error sending email: $e');
      return false;
    }
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
