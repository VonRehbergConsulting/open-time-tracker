import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/settings/domain/settings_repository.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:rxdart/rxdart.dart';

/// [SharedPreferences]-backed implementation of [SettingsRepository].
///
/// The current [themeMode] is cached in memory so synchronous reads
/// (needed by [MaterialApp.themeMode]) never block on disk. The cache
/// is populated lazily via [load] on first access, and kept
/// authoritative on writes via [setThemeMode].
class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._storage);

  final PreferencesStorage _storage;

  static const _themeModeKey = 'settings.themeMode';

  /// String representation persisted to prefs. Uses explicit tokens
  /// (not [ThemeMode.name]) so future enum additions don't accidentally
  /// change the on-disk format.
  static const _systemToken = 'system';
  static const _lightToken = 'light';
  static const _darkToken = 'dark';

  ThemeMode _current = ThemeMode.system;
  bool _loaded = false;

  final BehaviorSubject<ThemeMode> _subject = BehaviorSubject<ThemeMode>.seeded(
    ThemeMode.system,
  );

  @override
  ThemeMode get themeMode => _current;

  @override
  Stream<ThemeMode> observeThemeMode() => _subject.stream;

  @override
  Future<void> load() async {
    if (_loaded) return;
    final raw = await _storage.getString(_themeModeKey);
    _current = _decode(raw);
    _subject.add(_current);
    _loaded = true;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _current && _loaded) return;
    _current = mode;
    _loaded = true;
    _subject.add(mode);
    await _storage.setString(_themeModeKey, _encode(mode));
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return _systemToken;
      case ThemeMode.light:
        return _lightToken;
      case ThemeMode.dark:
        return _darkToken;
    }
  }

  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case _lightToken:
        return ThemeMode.light;
      case _darkToken:
        return ThemeMode.dark;
      case _systemToken:
      case null:
        return ThemeMode.system;
      default:
        // Unknown value written by a future build — behave like a
        // fresh install rather than crashing on downgrade.
        debugPrint('LocalSettingsRepository: unknown themeMode "$raw"');
        return ThemeMode.system;
    }
  }
}
