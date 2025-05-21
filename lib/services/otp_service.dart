import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPService {
  final _supabase = Supabase.instance.client;
  final _storage = GetStorage();
  static const String _verifiedEmailKey = 'verified_email';

  Future<bool> sendOTP(String email) async {
    try {
      final response = await _supabase.functions.invoke('send-otp', body: {
        'email': email,
      });
      
      if (response.status == 200) {
        return true;
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        throw errorData?['error'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await _supabase.functions.invoke('verify-otp', body: {
        'email': email,
        'otp': otp,
      });

      if (response.status == 200) {
        // Save the verified email in local storage
        await _storage.write(_verifiedEmailKey, email);
        return true;
      } else {
        final errorData = response.data as Map<String, dynamic>?;
        throw errorData?['error'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  String? getVerifiedEmail() {
    return _storage.read<String>(_verifiedEmailKey);
  }

  Future<void> clearVerifiedEmail() async {
    await _storage.remove(_verifiedEmailKey);
  }
}
