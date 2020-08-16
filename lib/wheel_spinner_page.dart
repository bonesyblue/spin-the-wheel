import 'dart:math';

import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class WheelSpinnerPage extends StatefulWidget {
  @override
  State<WheelSpinnerPage> createState() => _WheelSpinnerPageState();
}

// Page to display the wheel painter
class _WheelSpinnerPageState extends State<WheelSpinnerPage> {
  // Wheel properties
  final diameter = 250.0;
  final localCenterpoint = Offset(125, 125);

  // Add a dynamic count property to update when the wheel is spun
  int count = 0;

  // Keep a reference to the drag start position during drag movement
  Offset dragStartPosition;
  double offsetAngle = 0;

  @override
  Widget build(BuildContext context) {
    final countLabelStyle = Theme.of(context)
        .textTheme
        .headline4
        .copyWith(fontWeight: FontWeight.bold);

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Count: $count", style: countLabelStyle),
          SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onPanStart: this.onPanStart,
              onPanUpdate: this.onPanUpdate,
              onPanEnd: this.onPanEnd,
              child: Container(
                width: diameter,
                height: diameter,
                child: CustomPaint(
                  painter: WheelPainter(offset: offsetAngle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    setState(() {
      this.dragStartPosition = details.localPosition;
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    // Calcuate angle delta of drag relative to the centerpoint
    Offset dragStart = dragStartPosition - localCenterpoint;
    double deltaStart = atan2(dragStart.dy, dragStart.dx);

    Offset dragPosition = details.localPosition - localCenterpoint;
    double deltaEnd = atan2(dragPosition.dy, dragPosition.dx);

    double delta = deltaEnd - deltaStart;
    String deltaDeg = degrees(delta).toStringAsFixed(0);

    print("Drag delta angle (relative to circle center): $deltaDeg°");

    setState(() {
      offsetAngle = delta;
    });
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      this.dragStartPosition = null;
    });
  }
}
