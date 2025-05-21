import 'package:flutter_application_2/home.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get to => Get.find();

  @override
  void onReady() {
    // Redirect to home screen
    Get.offAll(const Home());
  }
}
