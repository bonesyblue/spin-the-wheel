import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';

class WheelSpinnerPage extends StatefulWidget {
  @override
  State<WheelSpinnerPage> createState() => _WheelSpinnerPageState();
}

// Page to display the wheel painter
class _WheelSpinnerPageState extends State<WheelSpinnerPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onPanStart: this.onPanStart,
        onPanUpdate: this.onPanUpdate,
        onPanEnd: this.onPanEnd,
        child: Center(
          child: Container(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: WheelPainter(),
            ),
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    debugPrint("Pan start: $details");
  }

  void onPanUpdate(DragUpdateDetails details) {
    debugPrint("Pan update: $details");
  }

  void onPanEnd(DragEndDetails details) {
    debugPrint("Pan end: $details");
  }
}
