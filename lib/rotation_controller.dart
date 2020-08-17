import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class RotationDelegate extends ValueNotifier<double> {
  Offset _dragStartPosition;

  RotationDelegate(double value) : super(value);

  set dragStartPosition(Offset offset) => _dragStartPosition = offset;

  /// Rotate by the provided offset value
  ///
  void rotate({
    @required Offset localPosition,
    @required Offset center,
  }) {
    // Calcuate angle delta of drag relative to the centerpoint
    Offset dragStart = _dragStartPosition - center;
    double deltaStart = atan2(dragStart.dy, dragStart.dx);

    Offset dragPosition = localPosition - center;
    double deltaEnd = atan2(dragPosition.dy, dragPosition.dx);

    double delta = deltaEnd - deltaStart;

    this.value = delta;
  }

  /// Calculates the resting position of the rotated object.
  ///
  /// If [snapGridDelta] is set, the final resting position
  /// will be based on the snap grid.
  ///
  /// *  [snapGridDelta] The snap scale used. Defaults to 1°.
  void flingRotate({
    @required double velocity,
    @required AnimationController controller,
    @required Animation driver,
    double snapGridDelta = (1.0 * pi) / 180,
  }) {
    /// Retain a reference to the offset angle at which the
    /// fling gesture began
    double flingStartAngle = this.value;
    double flingStartDeg = degrees(flingStartAngle);
    print("Boom: start at $flingStartDeg");

    /// Calculate the fling resting value (destination) based on
    /// the fling velocity and snap to the "coarse" scale
    double flingRestAngle = (flingStartAngle + (velocity / (2 * pi)));
    double rem = flingRestAngle % snapGridDelta;

    flingRestAngle = (flingRestAngle - rem).roundToDouble();

    double flingRestDelta = (flingRestAngle - flingStartAngle).roundToDouble();

    double restDeg = degrees(flingRestAngle);
    int coarseDeltaDeg = degrees(snapGridDelta).toInt();
    print("Calculated: $restDeg, Delta: $coarseDeltaDeg");

    // Animate to the velocity value and stop when it is reached
    controller.duration = Duration(
      milliseconds: velocity.abs().toInt(),
    );
    driver = Tween(begin: 0.0, end: flingRestDelta).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.decelerate,
      ),
    )..addListener(
        () {
          double newOffset = flingStartAngle + driver.value;

          this.value = newOffset;
        },
      );

    controller
      ..reset()
      ..forward();
  }
}
