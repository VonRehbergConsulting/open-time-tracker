import 'package:flutter/material.dart';

class ChartTextstyle extends TextStyle {
  ChartTextstyle({
    double? fontSize,
  }) : super(
          color: Color.fromARGB(255, 38, 92, 185),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        );
}
