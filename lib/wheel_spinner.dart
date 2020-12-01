import 'dart:math';

import 'package:SpinTheWheel/circular_math.dart';
import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';

class WheelSpinner extends StatefulWidget {
  final double diameter;
  final Function(int count) onCountChanged;
  final rangeMin;
  final rangeMax;
  final rangeInterval;

  WheelSpinner({
    @required this.diameter,
    @required this.rangeInterval,
    @required this.rangeMax,
    this.onCountChanged,
    this.rangeMin = 0,
  });

  @override
  State<WheelSpinner> createState() => _WheelSpinnerState();
}

class _WheelSpinnerState extends State<WheelSpinner>
    with SingleTickerProviderStateMixin {
  // Animated values
  AnimationController _rotationAnimationController;
  Animation _rotation;

  // Physics utility classes
  SpinVelocity _spinVelocity;
  NonUniformCircularMotion _motion;

  double _currentDistance = 0.0;
  Offset _localPosition;
  bool _isBackwards;
  double _totalDuration = 0.0;
  double _initialCircularVelocity = 0.0;
  double rotationAngle = 0.0;
  double _coarseDividerAngle;
  int _currentDivider;

  double get coarseDividerCount =>
      1 +
      ((this.widget.rangeMax - this.widget.rangeMin) /
          this.widget.rangeInterval);

  @override
  void initState() {
    super.initState();

    // Configure the physics helper instances
    _spinVelocity = new SpinVelocity(
      diameter: widget.diameter,
    );
    _motion = new NonUniformCircularMotion(resistance: 1.0);
    _coarseDividerAngle = _motion.anglePerDivision(coarseDividerCount);

    // Initialise the rotation animation associated properties
    _rotationAnimationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );

    _rotation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: _rotationAnimationController,
      ),
    )..addListener(() {
        _updateAnimationValues();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.diameter,
          width: widget.diameter,
          child: GestureDetector(
            onPanUpdate: this.onPanUpdate,
            onPanEnd: this.onPanEnd,
            child: AnimatedBuilder(
              animation: _rotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: rotationAngle + _currentDistance,
                  child: CustomPaint(
                    painter: WheelPainter(
                      coarseDividerCount: coarseDividerCount,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 30),
        RaisedButton(
          child: Text("Rotate wheel"),
          onPressed: this.toggleAnimation,
        ),
      ],
    );
  }

  void onPanUpdate(DragUpdateDetails details) {
    // Need to calculate the delta between current position and start, with reference to the centerpoint
    final currentPosition = details.localPosition;
    final previousPosition = currentPosition - details.delta;
    final startTheta = _spinVelocity.offsetToRadians(previousPosition);
    final endTheta = _spinVelocity.offsetToRadians(currentPosition);
    final deltaTheta = endTheta - startTheta;

    final newRotationAngle = rotationAngle += deltaTheta;

    // Angle as a ratio to 2π
    double modulo = _motion.modulo(rotationAngle);

    // Get the closest divider
    int dividerCount = (modulo / _coarseDividerAngle).truncate();

    int prev = _currentDivider;

    _currentDivider = dividerCount;

    if (prev != _currentDivider) {
      widget.onCountChanged(_currentDivider);
    }

    setState(() {
      newRotationAngle.clamp(0, 1.5 * pi);
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (this._rotationAnimationController.isAnimating) return;

    var velocity = _spinVelocity.getVelocity(
      _localPosition,
      details.velocity.pixelsPerSecond,
    );

    _localPosition = null;

    _isBackwards = velocity < 0;
    // _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());
    // _totalDuration = _motion.duration(_initialCircularVelocity);

    // _rotationAnimationController.duration =
    //     Duration(milliseconds: (_totalDuration * 1000).round());

    // _rotationAnimationController.reset();
    // _rotationAnimationController.forward();
  }

  void toggleAnimation() {
    print(
      'toggleAnimation() ${this._rotationAnimationController.status} - ${this._rotationAnimationController.isAnimating}',
    );

    if (this._rotationAnimationController.isAnimating) {
      this._rotationAnimationController.stop();
    } else {
      this._rotationAnimationController.reset();
      this._rotationAnimationController.forward();
    }
  }

  void _updateAnimationValues() {
    if (_rotationAnimationController.isAnimating) {
      var currentTime = _totalDuration * _rotation.value;
      _currentDistance =
          _motion.distance(_initialCircularVelocity, currentTime);
      if (_isBackwards) {
        _currentDistance = -_currentDistance;
      }
    }

    double modulo = _motion.modulo(_currentDistance + rotationAngle);

    if (!_rotationAnimationController.isAnimating) {
      rotationAngle = modulo;
      _currentDistance = 0.0;
    }
  }

  void updateCurrentDivider() {
    // Angle as a ratio to 2π
    double modulo = _motion.modulo(rotationAngle);

    // Get the closest divider
    int dividerCount = (modulo / _coarseDividerAngle).truncate();

    int prev = _currentDivider;

    _currentDivider = dividerCount;

    if (prev != _currentDivider) {
      print(_currentDivider);
      widget.onCountChanged(_currentDivider);
    }
  }
}
