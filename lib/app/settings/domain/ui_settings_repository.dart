import 'package:flutter/material.dart';

/// User-scoped, persisted UI preferences (theme, and other purely
/// presentation-layer knobs added in the future).
///
/// Deliberately named with a `Ui` prefix to disambiguate from the
/// pre-existing `SettingsRepository` under `lib/modules/task_selection/`
/// which holds task-selection preferences (working hours, filters,
/// analytics consent). Two unrelated types with identical names made
/// imports and DI registrations ambiguous.
abstract class UiSettingsRepository {
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
