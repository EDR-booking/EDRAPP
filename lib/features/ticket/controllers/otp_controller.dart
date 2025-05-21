import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/otp_service.dart';

class OTPController extends GetxController {
  final OTPService _otpService = OTPService();
  final _storage = GetStorage();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString email = ''.obs;
  final RxString otp = ''.obs;
  final RxBool isEmailVerified = false.obs;
  final RxBool isOTPSent = false.obs;
  final RxInt countdown = 60.obs; // 60 seconds countdown for resend OTP
  
  @override
  void onInit() {
    super.onInit();
    // Check if email is already verified
    final verifiedEmail = _otpService.getVerifiedEmail();
    if (verifiedEmail != null) {
      email.value = verifiedEmail;
      isEmailVerified.value = true;
    }
  }

  Future<void> sendOTP() async {
    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _otpService.sendOTP(email.value);
      isOTPSent.value = true;
      startCountdown();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOTP() async {
    if (otp.isEmpty) {
      errorMessage.value = 'Please enter the OTP';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final isVerified = await _otpService.verifyOTP(email.value, otp.value);
      if (isVerified) {
        isEmailVerified.value = true;
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void startCountdown() {
    countdown.value = 60; // Reset countdown to 60 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (countdown.value > 0) {
        countdown.value--;
        return true;
      }
      return false;
    });
  }

  bool get canResendOTP => countdown.value == 0;

  void resetOTPVerification() {
    otp.value = '';
    isOTPSent.value = false;
    isEmailVerified.value = false;
    _otpService.clearVerifiedEmail();
  }
}
