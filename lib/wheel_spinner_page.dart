import 'dart:math';
import 'dart:core';

import 'package:SpinTheWheel/rotation_delegate.dart';
import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:SpinTheWheel/wheel_spinner.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:provider/provider.dart';

const VELOCITY_DAMPING_COEFFICIENT = 0.1;

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
  int ticksPassed = 0;
  bool isIncreasing = false;

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

    if (mappedCount != this.ticksPassed) {
      setState(() {
        this.ticksPassed = mappedCount.clamp(0, 24);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialise the animation values to a fixed zero value
    flingAnimation = AlwaysStoppedAnimation(0.0);
    flingAnimationController = AnimationController(vsync: this);
    rotationDelegate = new RotationDelegate(
      rotationalCenter: localCenterpoint,
      maxValue: 450,
      minValue: 0,
    );
  }

  @override
  void dispose() {
    super.dispose();
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
          Text(
            "Count: $count",
            style: countLabelStyle,
          ),
          SizedBox(height: 16),
          Center(
            child: WheelSpinner(
              diameter: this.diameter,
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
    rotationDelegate.panStartPosition = details.localPosition;
  }

  void onPanUpdate(DragUpdateDetails details) {
    flingAnimationController.stop();
    flingAnimation = AlwaysStoppedAnimation(0.0);

    // Calcuate angle delta of drag relative to the centerpoint
    rotationDelegate.rotate(
      position: details.localPosition,
    );
  }

  void onPanEnd(DragEndDetails details) {
    int newCount = this.count;
    int _max = 72;
    int min = 0;
    if (isIncreasing) {
      newCount += ticksPassed;
    } else {
      newCount -= ticksPassed;
    }
    newCount = newCount.clamp(min, _max);

    setState(() {
      this.count = newCount;
    });

    rotationDelegate.panStartPosition = null;

    Velocity velocity = details.velocity;
    double maxVelocity = VELOCITY_DAMPING_COEFFICIENT *
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
