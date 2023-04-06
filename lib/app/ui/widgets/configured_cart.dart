import 'package:flutter/material.dart';

class ConfiguredCard extends StatelessWidget {
  final Widget child;
  const ConfiguredCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: child,
    );
  }
}
