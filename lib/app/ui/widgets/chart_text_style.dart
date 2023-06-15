import 'package:flutter/material.dart';

class ChartTextStyle extends TextStyle {
  const ChartTextStyle({
    double? fontSize,
  }) : super(
          color: const Color.fromARGB(255, 38, 92, 185),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        );
}
