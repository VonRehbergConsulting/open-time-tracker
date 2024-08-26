import 'package:flutter/material.dart';

class FilledButton extends StatelessWidget {
  final String? text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;

  const FilledButton({
    super.key,
    this.text,
    this.textStyle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: onPressed != null
            ? WidgetStateProperty.all(Theme.of(context).primaryColor)
            : null,
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        minimumSize: WidgetStateProperty.all<Size>(const Size(48.0, 48.0)),
        splashFactory: NoSplash.splashFactory,
        shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
      child: text != null
          ? Text(
              text!,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 16,
                  ),
            )
          : null,
    );
  }
}
