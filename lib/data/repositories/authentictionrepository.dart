import 'package:flutter_application_2/features/authentication/screens/onBording/onbording_screen.dart';
import 'package:flutter_application_2/home.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get to => Get.find();

  @override
  void onReady() {
    // TODO: implement onReady
    screenRedirect();
  }
}

void screenRedirect() {
  final deviceStorage = GetStorage();
  final isFirstTime = deviceStorage.read('isFirstTime') ?? true;
  isFirstTime ? Get.offAll(const OnbordingScreen()) : Get.offAll(const Home());
}
