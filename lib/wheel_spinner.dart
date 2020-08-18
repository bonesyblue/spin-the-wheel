import 'package:SpinTheWheel/circular_math.dart';
import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';

class WheelSpinner extends StatefulWidget {
  final int coarseDividerCount;
  final double diameter;
  final Function(int count) onCountChanged;

  WheelSpinner({
    @required this.diameter,
    this.coarseDividerCount = 24,
    this.onCountChanged,
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
  double _initialSpinAngle = 0.0;
  double _coarseDividerAngle;
  int _currentDivider;

  @override
  void initState() {
    super.initState();

    // Configure the physics helper instances
    _spinVelocity = new SpinVelocity(
      diameter: widget.diameter,
    );
    _motion = new NonUniformCircularMotion(resistance: 1.0);
    _coarseDividerAngle = _motion.anglePerDivision(widget.coarseDividerCount);

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
        widget.onCountChanged(_currentDivider);
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
                  angle: _initialSpinAngle + _currentDistance,
                  child: CustomPaint(
                    painter: WheelPainter(
                      coarseDividerCount: widget.coarseDividerCount,
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

    this.updateCurrentDivider();

    double modulo = _motion.modulo(_currentDistance + _initialSpinAngle);

    if (!_rotationAnimationController.isAnimating) {
      _initialSpinAngle = modulo;
      _currentDistance = 0.0;
    }
  }

  void updateCurrentDivider() {
    double modulo = _motion.modulo(_currentDistance + _initialSpinAngle);
    int prev = _currentDivider;
    _currentDivider =
        widget.coarseDividerCount - (modulo ~/ _coarseDividerAngle);

    if (prev != _currentDivider) {
      widget.onCountChanged(_currentDivider);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    _localPosition = details.localPosition;
    var angle = _spinVelocity.offsetToRadians(_localPosition);

    this.updateCurrentDivider();

    setState(() {
      _initialSpinAngle = angle;
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
    _initialCircularVelocity = pixelsPerSecondToRadians(velocity.abs());
    _totalDuration = _motion.duration(_initialCircularVelocity);

    _rotationAnimationController.duration =
        Duration(milliseconds: (_totalDuration * 1000).round());

    _rotationAnimationController.reset();
    _rotationAnimationController.forward();
  }
}
