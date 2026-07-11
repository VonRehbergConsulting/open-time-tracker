import 'package:flutter/material.dart';

/// User-scoped, persisted UI settings.
///
/// Currently only carries the app-wide [ThemeMode] override, but is the
/// natural home for any future preferences that shouldn't live in
/// [AppStateRepository] (which is session/navigation state).
abstract class SettingsRepository {
  /// The user's persisted theme-mode override. Defaults to
  /// [ThemeMode.system] until explicitly changed.
  ThemeMode get themeMode;

  /// Broadcast stream of setting changes. Emits the current
  /// [ThemeMode] on every mutation so [MaterialApp] can rebuild
  /// without polling.
  Stream<ThemeMode> observeThemeMode();

  /// Persists [mode] and notifies [observeThemeMode] listeners.
  Future<void> setThemeMode(ThemeMode mode);

  /// Loads persisted settings into memory. Must be awaited during
  /// bootstrap before the first [MaterialApp] frame so the correct
  /// theme is applied on cold start (no light-mode flash).
  Future<void> load();
}
