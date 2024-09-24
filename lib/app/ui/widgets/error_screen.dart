import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';

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
    final deviceSize = MediaQuery.of(context).size;
    final buttonPadding = deviceSize.width * 0.20;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: buttonPadding),
              child: FilledButton(
                onPressed: action,
                text: buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
