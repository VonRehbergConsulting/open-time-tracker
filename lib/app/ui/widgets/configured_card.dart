import 'package:flutter/material.dart';

class ConfiguredCard extends StatelessWidget {
  final Widget child;

  const ConfiguredCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Deliberately do NOT set `color` — the Card widget picks up the
    // theme's cardColor / surface tone automatically, which is white
    // in light mode and an elevated dark-grey surface in dark mode.
    // Hard-coding `Colors.white` here previously kept every card white
    // in dark mode, hiding all text on them.
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18.0)),
      ),
      child: child,
    );
  }
}
