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
      child: Text(
        text,
        style: textStyle ??
            TextStyle(
              fontSize: 16,
            ),
      ),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        minimumSize: MaterialStateProperty.all<Size>(Size(48.0, 48.0)),
        splashFactory: NoSplash.splashFactory,
        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
      ),
    );
  }
}
