import 'dart:math';

import 'package:flutter/material.dart';

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY);

    final centerpoint = Offset(centerX, centerY);

    final wheelBackgroundBrush = Paint()
      ..color = Colors.pink
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      centerpoint,
      radius,
      wheelBackgroundBrush,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
