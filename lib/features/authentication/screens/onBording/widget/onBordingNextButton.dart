import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/authentication/controllers/onboarding/onbording_controlller.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';
import 'package:flutter_application_2/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class OnBordingNextButton extends StatelessWidget {
  const OnBordingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return ElevatedButton(
      onPressed: () {
        OnbordingControlller.instance.nextPage();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: dark ? TColors.light : TColors.black,
        shape: const CircleBorder(),
      ),
      child: const Icon(Iconsax.arrow_right_3),
    );
  }
}
