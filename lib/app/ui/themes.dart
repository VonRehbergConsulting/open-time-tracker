import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Central [ThemeData] factory for the app.
///
/// Both [light] and [dark] are derived from the same brand seed so
/// primary-tinted surfaces (FAB, chips, popup, bottom-sheet) stay
/// consistent across modes. Only the surface / background / on-surface
/// colors flip; the brand blue is a fixed anchor.
class AppTheme {
  AppTheme._();

  /// Brand primary — used as the ColorScheme seed and forced as the
  /// literal [ColorScheme.primary] value so tinted surfaces render the
  /// exact brand shade in both modes.
  static const Color brandBlue = Color.fromRGBO(38, 92, 185, 1);

  /// Complementary teal used for gradient accents (e.g. profile
  /// header, total-time card). Same in both modes for brand
  /// continuity.
  static const Color brandTeal = Color.fromRGBO(33, 147, 147, 1);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandBlue,
      primary: brandBlue,
      brightness: brightness,
    );

    // Neutral background pair. Kept as literal colors (rather than
    // colorScheme.surface) so the app matches the platform-native
    // "very light grey" scaffold on iOS in light mode, and a
    // comfortably-dark (but not pure-black) surface in dark mode.
    final scaffoldBackground = brightness == Brightness.light
        ? const Color.fromARGB(255, 249, 249, 249)
        : const Color(0xFF121212);
    final appBarBackground = brightness == Brightness.light
        ? const Color.fromARGB(255, 243, 243, 243)
        : const Color(0xFF1E1E1E);
    final appBarForeground = brightness == Brightness.light
        ? Colors.black
        : Colors.white;

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      primaryColor: brandBlue,
      fontFamily: 'Cupertino',
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: brandBlue),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: brandBlue,
        brightness: brightness,
      ),
    );
  }
}
