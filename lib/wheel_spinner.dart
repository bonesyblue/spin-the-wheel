import 'dart:math';

import 'package:SpinTheWheel/wheel_painter.dart';
import 'package:flutter/material.dart';

class WheelSpinner extends StatefulWidget {
  final int coarseDividerCount;
  final double diameter;

  WheelSpinner({
    @required this.diameter,
    this.coarseDividerCount = 24,
  });

  @override
  State<WheelSpinner> createState() => _WheelSpinnerState();
}

class _WheelSpinnerState extends State<WheelSpinner>
    with SingleTickerProviderStateMixin {
  // Animated values
  AnimationController rotationAnimationController;
  Animation rotation;

  @override
  void initState() {
    super.initState();

    rotationAnimationController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );

    rotation = Tween(
      begin: 0.0,
      end: 2 * pi,
    ).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: rotationAnimationController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.diameter,
          width: widget.diameter,
          child: GestureDetector(
            onPanStart: this.onPanStart,
            onPanUpdate: this.onPanUpdate,
            onPanEnd: this.onPanEnd,
            child: AnimatedBuilder(
              animation: rotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: rotation.value,
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
      'toggleAnimation() ${this.rotationAnimationController.status} - ${this.rotationAnimationController.isAnimating}',
    );

    if (this.rotationAnimationController.isAnimating) {
      this.rotationAnimationController.stop();
    } else {
      this.rotationAnimationController.reset();
      this.rotationAnimationController.forward();
    }
  }

  void onPanStart(DragStartDetails details) {}
  void onPanUpdate(DragUpdateDetails details) {}
  void onPanEnd(DragEndDetails details) {}
}
