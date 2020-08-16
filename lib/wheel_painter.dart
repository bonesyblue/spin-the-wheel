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

    final wheelPinBrush = Paint()..color = Colors.white;

    canvas.drawCircle(
      centerpoint,
      6,
      wheelPinBrush,
    );

    final coarseScaleCount = 24;
    final coarseScaleInnerRadius = radius - 24;

    drawScaleLines(
      count: coarseScaleCount,
      center: centerpoint,
      outerRadius: radius,
      innerRadius: coarseScaleInnerRadius,
      canvas: canvas,
    );

    final fineScaleCount = coarseScaleCount * 5;
    final fineScaleInnerRadius = radius - 12;

    drawScaleLines(
      count: fineScaleCount,
      center: centerpoint,
      outerRadius: radius,
      innerRadius: fineScaleInnerRadius,
      canvas: canvas,
    );
  }

  void drawScaleLines({
    @required int count,
    @required Offset center,
    @required double outerRadius,
    @required double innerRadius,
    @required Canvas canvas,
  }) {
    final double deltaAngle = (2 * pi) / count;
    for (var i = 0; i <= count; i++) {
      final alphaAngle = (i * deltaAngle);
      final startOffsetY = center.dy + (outerRadius * sin(alphaAngle));
      final startOffsetX = center.dx + (outerRadius * cos(alphaAngle));

      final endOffsetY = center.dy + (innerRadius * sin(alphaAngle));
      final endOffsetX = center.dx + (innerRadius * cos(alphaAngle));

      final start = Offset(startOffsetX, startOffsetY);
      final end = Offset(endOffsetX, endOffsetY);

      final indicatorBrush = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0;

      canvas.drawLine(start, end, indicatorBrush);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
