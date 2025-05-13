import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/authentication/controllers/onboarding/onbording_controlller.dart';
import 'package:flutter_application_2/features/authentication/screens/onBording/widget/onBordingNextButton.dart';
import 'package:flutter_application_2/features/authentication/screens/onBording/widget/onbordering_page.dart';
import 'package:flutter_application_2/features/authentication/screens/onBording/widget/onbording_dot_navigation.dart';
import 'package:flutter_application_2/features/authentication/screens/onBording/widget/skip_button.dart';
import 'package:flutter_application_2/utils/constants/image_strings.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/constants/text_strings.dart';
import 'package:flutter_application_2/utils/device/device_utility.dart';
import 'package:get/get.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnbordingControlller controller = Get.put(OnbordingControlller());

    return Scaffold(
      body: Stack(
        children: [
          // page View
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.currentIndex.call,
            children: const [
              onBordingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subTitle: TTexts.onBoardingSubTitle1,
              ),
              onBordingPage(
                image: TImages.onBoardingImage2,
                title: TTexts.onBoardingTitle2,
                subTitle: TTexts.onBoardingSubTitle2,
              ),
              onBordingPage(
                image: TImages.onBoardingImage3,
                title: TTexts.onBoardingTitle3,
                subTitle: TTexts.onBoardingSubTitle3,
              ),
            ],
          ),
          //Skip Buutton
          const Positioned(
            top: 30,
            right: TSizes.spaceBtwItems,
            child: SkipTextButton(),
          ),

          //On bording dot Navigatiomn
          const OnBordingDotNavigation(),

          Positioned(
            bottom: TDeviceUtils.getBottomNavigationBarHeight() + 25,
            right: TSizes.defaultSpace,
            child: const OnBordingNextButton(),
          ),
        ],
      ),
    );
  }
}
