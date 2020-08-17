import 'dart:math';

import 'package:SpinTheWheel/rotation_controller.dart';
import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class WheelSpinnerPage extends StatefulWidget {
  @override
  State<WheelSpinnerPage> createState() => _WheelSpinnerPageState();
}

// Page to display the wheel painter
class _WheelSpinnerPageState extends State<WheelSpinnerPage>
    with SingleTickerProviderStateMixin {
  // Wheel properties
  final diameter = 250.0;
  final localCenterpoint = Offset(125, 125);

  // Add a dynamic count property to update when the wheel is spun
  int count = 0;

  // Keep a reference to the drag start position during drag movement
  Offset dragStartPosition;
  double offsetAngle = 0;

  // Fling animation properties
  AnimationController flingAnimationController;
  Animation flingAnimation;

  RotationDelegate rotationDelegate;

  int coarseScaleCount = 24;

  void onRotationValueChanged() {
    double delta = (2 * pi) / coarseScaleCount;

    // Map delegate value to count
    double rotationRadians = rotationDelegate.value;
    double rotationDegrees = degrees(rotationRadians);

    print("Updated: $rotationDegrees");

    /// The update handler must calculate the whole number of
    /// coarse scale points that the wheel has passed in the
    /// current active pan gesture
    int mappedCount = (rotationRadians / delta).floor();
    print("Count: $mappedCount");

    if (mappedCount < 0) {
      mappedCount = 24 + mappedCount;
    }

    setState(() {
      this.count = mappedCount;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialise the animation values to a fixed zero value
    flingAnimation = AlwaysStoppedAnimation(0.0);
    flingAnimationController = AnimationController(vsync: this);
    rotationDelegate = new RotationDelegate(0.0);
    rotationDelegate.addListener(onRotationValueChanged);
  }

  @override
  void dispose() {
    super.dispose();
    rotationDelegate.removeListener(onRotationValueChanged);
  }

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
                child: ValueListenableBuilder(
                  valueListenable: rotationDelegate,
                  builder: (context, value, child) => CustomPaint(
                    painter: WheelPainter(
                      offset: value,
                      coarseLineCount: coarseScaleCount,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    flingAnimationController.stop();
    flingAnimation = AlwaysStoppedAnimation(0.0);

    // Set the drag reference position
    rotationDelegate.dragStartPosition = details.localPosition;
  }

  void onPanUpdate(DragUpdateDetails details) {
    flingAnimationController.stop();
    flingAnimation = AlwaysStoppedAnimation(0.0);

    // Calcuate angle delta of drag relative to the centerpoint
    rotationDelegate.rotate(
      localPosition: details.localPosition,
      center: localCenterpoint,
    );
  }

  void onPanEnd(DragEndDetails details) {
    rotationDelegate.dragStartPosition = null;

    Velocity velocity = details.velocity;
    double maxVelocity = 0.025 *
        max(
          velocity.pixelsPerSecond.dx,
          velocity.pixelsPerSecond.dy,
        ).roundToDouble();
    debugPrint("Drag ended with velocity: $maxVelocity");

    if (maxVelocity == 0.0) {
      print("Drag ended with no fling.");
      return;
    }

    double coarseDelta = (2 * pi) / coarseScaleCount;

    rotationDelegate.flingRotate(
      controller: flingAnimationController,
      driver: flingAnimation,
      snapGridDelta: coarseDelta,
      velocity: maxVelocity,
    );
  }
}
