import 'package:flutter/material.dart';
import 'package:flutter_application_2/utils/constants/colors.dart';

import '../curved_shape/curved_shape.dart';
import 'circular_container.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TCurvedShape(),
      child: Container(
        color: TColors.primary,

        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -50,
                child: TCircularContainer(
                  color: TColors.light.withOpacity(0.1),
                ),
              ),
              Positioned(
                bottom: -10,
                right: -50,
                child: TCircularContainer(
                  color: TColors.light.withOpacity(0.1),
                ),
              ),

              child,
            ],
          ),
        ),
      ),
    );
  }
}
