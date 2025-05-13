import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lottie/lottie.dart';

import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class TFullScreenloader {

  static void openLoadingDialog(String text,String animation){
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!) 
              ? TColors.dark 
              : TColors.light,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                animation,
                width: double.infinity,
                height: double.infinity,
              ),
              const SizedBox(height: 20),
              Text(
                text,
                style: TextStyle(
                  color: THelperFunctions.isDarkMode(Get.context!) 
                      ? TColors.light 
                      : TColors.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static stopLoading() {
    if (Get.isDialogOpen == true) Get.back();
  }
}