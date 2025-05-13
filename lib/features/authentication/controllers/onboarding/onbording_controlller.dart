import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnbordingControlller extends GetxController {
  static OnbordingControlller get instance => Get.find();

  final pageController = PageController();
  var currentIndex = 0.obs;

  void changeIndex(index) {
    currentIndex.value = index;
  }

  void dotNavigationClick(int index) {
    if (index == 2) {
      Get.toNamed('/email');
    } else {
      currentIndex.value = index;
      pageController.jumpToPage(index); // Use jumpToPage instead of jumpTo
    }
  }

  void skipPage() {
    if (currentIndex.value < 2) {
      int page = currentIndex.value + 1;
      pageController.jumpToPage(page);
    } else {
      Get.toNamed('/email');
    }
  }

  void nextPage() {
    if (currentIndex.value < 2) {
      int page = currentIndex.value + 1;
      pageController.jumpToPage(page);
    } else {
      Get.toNamed('/email');
    }
  }
}
