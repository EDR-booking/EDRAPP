import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/authentication/controllers/onboarding/onbording_controlller.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/device/device_utility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBordingDotNavigation extends StatelessWidget {
  const OnBordingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnbordingControlller.instance;

    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: TSizes.defaultSpace,

      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: const ExpandingDotsEffect(activeDotColor: TColors.black),
      ),
    );
  }
}
