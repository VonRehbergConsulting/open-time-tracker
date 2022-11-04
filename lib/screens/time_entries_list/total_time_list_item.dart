import 'package:flutter/material.dart';

class TotalTimeListItem extends StatelessWidget {
  final String text;
  const TotalTimeListItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey),
        textAlign: TextAlign.left,
      ),
    );
  }
}
