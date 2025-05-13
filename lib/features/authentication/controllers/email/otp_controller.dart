import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/authentication/controllers/email/email_verification_controller.dart';
import 'package:flutter_application_2/features/authentication/services/email_service_new.dart';
import 'package:flutter_application_2/home.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OTPController extends GetxController {
  final otpController = TextEditingController();
  // Making EmailVerificationController optional to avoid errors
  EmailVerificationController? get emailVerificationController => 
      Get.isRegistered<EmailVerificationController>() ? Get.find<EmailVerificationController>() : null;
  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;
  final RxString email = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasExpired = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Get the email from arguments if available
    if (Get.arguments != null && Get.arguments is String) {
      email.value = Get.arguments;
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      errorMessage.value = 'Please enter a valid 6-digit OTP';
      return;
    }
    
    try {
      isVerifying.value = true;
      errorMessage.value = '';
      
      final isValid = await EmailService.verifyOTP(email.value, otpController.text);
      
      if (isValid) {
        // Navigate to success screen or next step
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Save the verified email in GetStorage
        final box = GetStorage();
        await box.write('verifiedEmail', email.value);

        Get.to(() => Home());
      } else {
        hasExpired.value = true;
        errorMessage.value = 'Invalid or expired OTP. Please try again or request a new one.';
        Get.snackbar(
          'Error',
          'Invalid or expired OTP. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'Verification failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isVerifying.value = false;
    }
  }
  
  Future<void> resendOTP() async {
    try {
      isResending.value = true;
      errorMessage.value = '';
      hasExpired.value = false;
      
      final success = await EmailService.sendOTP(email.value);
      
      if (success) {
        Get.snackbar(
          'Success',
          'A new OTP has been sent to your email.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Clear the OTP field for a new entry
        otpController.clear();
      } else {
        errorMessage.value = 'Failed to send OTP. Please try again.';
        Get.snackbar(
          'Error',
          'Failed to send OTP. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }
  
  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
