import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ConfiguredShimmer extends StatelessWidget {
  final Widget child;

  const ConfiguredShimmer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEBEBF4),
      highlightColor: const Color(0xFFF4F4F4),
      child: child,
    );
  }
}
