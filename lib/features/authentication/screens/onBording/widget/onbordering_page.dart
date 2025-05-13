import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/constants/sizes.dart';
import 'package:flutter_application_2/utils/helpers/helper_functions.dart';

// ignore: camel_case_types
class onBordingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  const onBordingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            height: THelperFunctions.screenHeight() * 0.6,
            width: THelperFunctions.screenWidth() * 0.8,
            image: AssetImage(image),
          ),

          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
