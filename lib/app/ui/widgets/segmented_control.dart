import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SegmentedControl<T extends Object> extends StatelessWidget {
  final T groupValue;
  final Map<T, String> children;
  final Function(T?) onValueChanged;

  const SegmentedControl({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoSlidingSegmentedControl<T>(
      thumbColor: theme.primaryColor,
      groupValue: groupValue,
      children: children.map(
        (key, value) => MapEntry(
          key,
          Text(
            value,
            style: TextStyle(color: key == groupValue ? Colors.white : null),
          ),
        ),
      ),
      onValueChanged: onValueChanged,
    );
  }
}
