import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOtpService {
  static final SupabaseOtpService _instance = SupabaseOtpService._internal();

  factory SupabaseOtpService() {
    return _instance;
  }

  SupabaseOtpService._internal();

  // Get the Supabase client
  SupabaseClient get _client => Supabase.instance.client;

  // Send OTP to the provided email
  Future<bool> sendOTP(String email) async {
    try {
      // Invoke the edge function for sending OTP
      final response = await _client.functions.invoke('send-otp', 
        body: {'email': email}
      );

      if (response.status != 200) {
        throw Exception('Failed to send OTP: ${response.data}');
      }
      
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // Verify OTP code
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      // Invoke the edge function for verifying OTP
      final response = await _client.functions.invoke('verify-otp', 
        body: {'email': email, 'otp': otp}
      );

      if (response.status != 200) {
        throw Exception('Failed to verify OTP: ${response.data}');
      }
      
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
}
