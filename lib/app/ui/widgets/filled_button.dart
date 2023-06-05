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
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        minimumSize: MaterialStateProperty.all<Size>(const Size(48.0, 48.0)),
        splashFactory: NoSplash.splashFactory,
        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
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
