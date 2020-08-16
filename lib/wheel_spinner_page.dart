import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';

class WheelSpinnerPage extends StatefulWidget {
  @override
  State<WheelSpinnerPage> createState() => _WheelSpinnerPageState();
}

// Page to display the wheel painter
class _WheelSpinnerPageState extends State<WheelSpinnerPage> {
  // Add a dynamic count property to update when the wheel is spun
  int count = 0;

  // Keep a reference to the drag start position during drag movement
  Offset dragStartPosition;

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
          GestureDetector(
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
        ],
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    debugPrint("Pan start: $details");
    setState(() {
      this.dragStartPosition = details.globalPosition;
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    debugPrint("Pan update: $details");
  }

  void onPanEnd(DragEndDetails details) {
    debugPrint("Pan end: $details");
    setState(() {
      this.dragStartPosition = null;
    });
  }
}
