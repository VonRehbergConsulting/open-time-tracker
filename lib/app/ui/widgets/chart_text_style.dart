import 'package:flutter/material.dart';

class ChartTextStyle extends TextStyle {
  ChartTextStyle({
    double? fontSize,
  }) : super(
          color: Color.fromARGB(255, 38, 92, 185),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        );
}
