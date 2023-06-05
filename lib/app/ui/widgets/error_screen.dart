import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback action;

  const ErrorScreen({
    required this.text,
    required this.buttonText,
    required this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            const SizedBox(height: 16.0),
            CupertinoButton.filled(
              onPressed: action,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
