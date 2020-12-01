import 'package:SpinTheWheel/utils/app_logger.dart';
import 'package:SpinTheWheel/wheel_spinner_page.dart';
import 'package:flutter/material.dart';

void main() {
  /// Instantiate logging helper
  AppLogger(logIdentifier: "STW");

  /// Run the aoo
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Spin the wheel"),
        ),
        body: WheelSpinnerPage(),
      ),
    );
  }
}
