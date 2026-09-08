
import 'package:flutter/material.dart';

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(size.width * 0.35, 0);

    path.cubicTo(
      size.width * 0.55,
      size.height * 0.10,
      size.width * 0.80,
      size.height * 0.08,
      size.width,
      size.height * 0.35,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}