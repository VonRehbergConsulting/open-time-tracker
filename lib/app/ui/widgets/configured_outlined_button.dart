import 'package:flutter/material.dart';

class ConfiguredOutlinedButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;

  const ConfiguredOutlinedButton({
    super.key,
    required this.text,
    this.textStyle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        minimumSize: WidgetStateProperty.all<Size>(const Size(48.0, 48.0)),
        splashFactory: NoSplash.splashFactory,
        shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor:
            WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
      ),
      child: Text(
        text,
        style: textStyle ??
            const TextStyle(
              fontSize: 16,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
