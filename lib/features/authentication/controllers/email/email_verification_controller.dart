import 'package:get/get.dart';
import '../../services/email_service_new.dart';

class EmailVerificationController extends GetxController {
  static EmailVerificationController get to => Get.find();
  final RxBool isLoading = false.obs;
  final RxBool isEmailSent = false.obs;
  final RxString error = ''.obs;
  final RxString email = ''.obs;

  Future<void> sendOTP(String emailAddress) async {
    try {
      isLoading.value = true;
      error.value = '';
      email.value = emailAddress;

      final success = await EmailService.sendOTP(emailAddress);
      if (success) {
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
  
  void clearError() {
    error.value = '';
  }
}
