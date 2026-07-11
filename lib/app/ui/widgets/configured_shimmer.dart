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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Shimmer needs a base tone slightly darker than the highlight so the
    // moving band reads as a soft "sheen". The M3 palette does not expose
    // a pair with that exact relationship in both brightnesses, so we pick
    // explicit greys matched to each mode.
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}
