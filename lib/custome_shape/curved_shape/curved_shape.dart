import 'package:flutter/material.dart';

class TCurvedShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
 
 var path=Path();

 path.lineTo(0, size.height);

 var firstCurve=Offset(0, size.height-30);
 var lastCurve=Offset(30, size.height-30);

 path.quadraticBezierTo(firstCurve.dx, firstCurve.dy, lastCurve.dx, lastCurve.dy);

  var secondFirstCurve=Offset(size.width-30, size.height-30);
  var seconddLastCurve=Offset(size.width-30, size.height-30);


 path.quadraticBezierTo(secondFirstCurve.dx, secondFirstCurve.dy, seconddLastCurve.dx, seconddLastCurve.dy);

 var thirdFirstCurve=Offset(size.width, size.height-30);
  var thirdLastCurve=Offset(size.width, size.height);


 path.quadraticBezierTo(thirdFirstCurve.dx, thirdFirstCurve.dy, thirdLastCurve.dx, thirdLastCurve.dy);


 

path.lineTo(size.width, 0);
 path.close();
 return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
   return true;
  }

}