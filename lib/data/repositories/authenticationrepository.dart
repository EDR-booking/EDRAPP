import 'package:flutter_application_2/features/authentication/screens/onBording/onbording_screen.dart';
import 'package:flutter_application_2/home.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get to => Get.find();

  @override
  void onReady() {
    super.onReady();
    screenRedirect();
  }

  void screenRedirect() {
    final deviceStorage = GetStorage();
    final isFirstTime = deviceStorage.read('isFirstTime') ?? true;
    if (isFirstTime) {
      Get.offAll(const OnbordingScreen());
    } else {
      Get.offAll(const Home());
    }
  }
}
