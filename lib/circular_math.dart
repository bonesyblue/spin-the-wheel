// With thanks to https://github.com/davidanaya/flutter-spinning-wheel/blob/master/lib/src/utils.dart
import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';

const Map<int, Offset> quadrants = const {
  1: Offset(0.5, 0.5),
  2: Offset(-0.5, 0.5),
  3: Offset(-0.5, -0.5),
  4: Offset(0.5, -0.5),
};

const pi_0_5 = pi * 0.5;
const pi_2_5 = pi * 2.5;
const pi_2 = pi * 2;

class SpinVelocity {
  final double diameter;

  double get radius => diameter / 2;

  SpinVelocity({
    @required this.diameter,
  });

  double getVelocity(Offset position, Offset pps) {
    var quadrantIndex = getQuadrantFromOffset(position);
    var quadrant = quadrants[quadrantIndex];
    return (quadrant.dx * pps.dx) + (quadrant.dy * pps.dy);
  }

  /// transforms (x,y) into radians with reference to the origin
  double offsetToRadians(Offset position) {
    var a = position.dx - radius;
    var b = radius - position.dy;
    var angle = atan2(b, a);
    return normalizeAngle(angle);
  }

  int getQuadrantFromOffset(Offset p) =>
      p.dx > radius ? (p.dy > radius ? 2 : 1) : (p.dy > radius ? 3 : 4);

  // radians go from 0 to pi (positive y axis) and 0 to -pi (negative y axis)
  // we need radians from positive y axis (0) clockwise back to y axis (2pi)
  double normalizeAngle(double angle) => angle > 0
      ? (angle > pi_0_5 ? (pi_2_5 - angle) : (pi_0_5 - angle))
      : pi_0_5 - angle;

  bool contains(Offset p) => Size(diameter, diameter).contains(p);
}

class NonUniformCircularMotion {
  final double resistance;

  NonUniformCircularMotion({@required this.resistance});

  /// returns the acceleration based on the resistance provided in the constructor
  double get acceleration => resistance * -7 * pi;

  /// distance covered in a specified time with initial velocity
  /// 𝜑=𝜑0+𝜔·𝑡+1/2·𝛼·𝑡2
  distance(double velocity, double time) =>
      (velocity * time) + (0.5 * acceleration * pow(time, 2));

  /// movement duration with initial velocity
  duration(double velocity) => -velocity / acceleration;

  /// modulo in a circumference
  modulo(dynamic angle) => angle % (2 * pi);

  /// angle per division in a circunference with x dividers
  anglePerDivision(double dividers) => (2 * pi) / dividers;
}

/// transforms pixels per second as used by Flutter to radians
/// this is a custom interpreation, it could be updated to adjust the velocity
double pixelsPerSecondToRadians(double pps) {
  // 100 ppx will equal 2pi radians
  return (pps * 2 * pi) / 1000;
}
