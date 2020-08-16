import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';

// Page to display the wheel painter
class WheelSpinnerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          child: CustomPaint(
            painter: WheelPainter(),
          ),
        ),
      ),
    );
  }
}
