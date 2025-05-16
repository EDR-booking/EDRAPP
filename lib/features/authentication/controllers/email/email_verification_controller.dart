import 'dart:async';
import 'package:get/get.dart';
import '../../services/email_service_new.dart';

class EmailVerificationController extends GetxController {
  static EmailVerificationController get to => Get.find();
  final RxBool isLoading = false.obs;
  final RxBool isEmailSent = false.obs;
  final RxString error = ''.obs;
  final RxString email = ''.obs;
  final RxBool isCooldownActive = false.obs;
  final RxInt cooldownSeconds = 0.obs;
  
  Timer? _cooldownTimer;
  
  // Cooldown period in seconds (120 seconds = 2 minutes)
  static const int cooldownPeriod = 120;

  // Start cooldown timer to prevent OTP spam
  void _startCooldownTimer() {
    // Cancel any existing timer
    _cooldownTimer?.cancel();
    
    // Set initial cooldown state
    cooldownSeconds.value = cooldownPeriod;
    isCooldownActive.value = true;
    
    // Start the timer
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (cooldownSeconds.value > 0) {
        cooldownSeconds.value--;
      } else {
        // Cooldown complete
        isCooldownActive.value = false;
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
      }
    });
  }
  
  Future<void> sendOTP(String emailAddress) async {
    // Prevent OTP spam - check if cooldown is active
    if (isCooldownActive.value) {
      error.value = 'Please wait ${cooldownSeconds.value} seconds before requesting another OTP.';
      return;
    }
    
    try {
      isLoading.value = true;
      error.value = '';
      email.value = emailAddress;

      final success = await EmailService.sendOTP(emailAddress);
      if (success) {
        // Start cooldown timer to prevent spam
        _startCooldownTimer();
        
        isEmailSent.value = true;
        Get.toNamed('/otp', arguments: emailAddress);
      } else {
        error.value = 'Failed to send OTP. Please try again.';
      }
    } catch (e) {
      error.value = 'An error occurred. Please try again.';
      print('Error sending OTP: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  void onClose() {
    // Clean up timers when controller is destroyed
    _cooldownTimer?.cancel();
    super.onClose();
  }
  
  void clearError() {
    error.value = '';
  }
}
