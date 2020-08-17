import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class RotationDelegate extends ChangeNotifier {
  Offset _panStartPosition;

  // (Input)
  int maxValue;
  int minValue;
  int coarseStepCount;
  int fineStepCount;
  Offset rotationalCenter;

  /// === Observable properties (Output) ===
  double alpha;
  double value;

  /// Delegate used in combination with a GestureDetector, to handle circular
  /// rotation of a widget.
  ///
  /// * [rotationalCenter] The centerpoint of the rotational movement
  /// * [alpha] The initial offset angle
  /// * [maxValue] The maxium value on the circular scale
  /// * [minValue] The minimum value on the circular scale
  /// * [coarseStepCount] The number of coarse scale markings
  /// * [fineStepCount] The number of fine scale markings
  RotationDelegate({
    @required this.maxValue,
    @required this.rotationalCenter,
    this.alpha = 0.0,
    this.coarseStepCount = 24,
    this.fineStepCount = 24 * 10,
    this.minValue = 0,
    this.value = 0.0,
  });

  /// Hold a mutable reference to the start offset of each pan
  /// gesture
  set panStartPosition(Offset offset) => _panStartPosition = offset;

  /// Rotate by the provided offset value
  void rotate({
    @required Offset position,
  }) {
    // Calcuate angle delta of drag relative to the centerpoint
    Offset dragStart = _panStartPosition - rotationalCenter;
    double deltaStart = atan2(dragStart.dy, dragStart.dx);

    Offset dragPosition = position - rotationalCenter;
    double deltaEnd = atan2(dragPosition.dy, dragPosition.dx);

    double delta = deltaEnd - deltaStart;

    /// Delta ranges between -pi -> 0 -> pi. This is mapped to a linear scale
    /// from 0 -> 2pi
    if (delta < 0) {
      delta = (2 * pi) + delta;
    }

    // TODO map angle to linear scale
    double scalingFactor = (2 * pi) / (maxValue - minValue);
    double newValue = scalingFactor * delta;

    notifyListeners();
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
