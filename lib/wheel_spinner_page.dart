import 'dart:core';

import 'package:SpinTheWheel/wheel_spinner.dart';
import 'package:flutter/material.dart';

class WheelSpinnerPage extends StatefulWidget {
  @override
  State<WheelSpinnerPage> createState() => _WheelSpinnerPageState();
}

// Page to display the wheel painter
class _WheelSpinnerPageState extends State<WheelSpinnerPage>
    with SingleTickerProviderStateMixin {
  double diameter = 250;
  int count = 0;

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
              onCountChanged: (count) {
                setState(() {
                  this.count = count;
                });
              },
              diameter: this.diameter,
            ),
          ),
        ],
      ),
    );
  }
}
