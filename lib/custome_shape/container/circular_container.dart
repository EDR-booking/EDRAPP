import 'package:flutter/material.dart';

class TCircularContainer extends StatelessWidget {
  const TCircularContainer({
    super.key,
    this.width = 100,
    this.height = 100,
    this.color = Colors.white,
    this.radius = 400,
    this.padding = 0,
    this.child,
    this.margin,
  });

  final double? width;
  final double? height;
  final Color color;
  final double radius;
  final double padding;
  final Widget? child;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
