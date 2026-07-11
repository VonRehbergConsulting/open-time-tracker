import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_project_time_tracker/app/settings/infrastructure/local_settings_repository.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to ThemeMode.system on a fresh install', () async {
    final repo = LocalSettingsRepository(PreferencesStorage());
    await repo.load();
    expect(repo.themeMode, ThemeMode.system);
  });

  test('setThemeMode updates the cached value and emits on the stream',
      () async {
    final repo = LocalSettingsRepository(PreferencesStorage());
    await repo.load();

    final emitted = <ThemeMode>[];
    final sub = repo.observeThemeMode().listen(emitted.add);

    await repo.setThemeMode(ThemeMode.dark);
    await repo.setThemeMode(ThemeMode.light);

    // Allow the BehaviorSubject to flush.
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(repo.themeMode, ThemeMode.light);
    // Seeded value + two writes.
    expect(emitted, [ThemeMode.system, ThemeMode.dark, ThemeMode.light]);
  });

  test('setThemeMode is a no-op when the value is unchanged', () async {
    final repo = LocalSettingsRepository(PreferencesStorage());
    await repo.load();
    await repo.setThemeMode(ThemeMode.dark);

    final emitted = <ThemeMode>[];
    final sub = repo.observeThemeMode().listen(emitted.add);

    await repo.setThemeMode(ThemeMode.dark);

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // BehaviorSubject seeds with current; the redundant setter must
    // not re-emit.
    expect(emitted, [ThemeMode.dark]);
  });

  test('persists the theme mode across repository instances', () async {
    final first = LocalSettingsRepository(PreferencesStorage());
    await first.load();
    await first.setThemeMode(ThemeMode.dark);

    final second = LocalSettingsRepository(PreferencesStorage());
    await second.load();

    expect(second.themeMode, ThemeMode.dark);
  });

  test('decodes an unknown persisted token as ThemeMode.system (safe '
      'downgrade path)', () async {
    SharedPreferences.setMockInitialValues({
      'settings.themeMode': 'high-contrast', // hypothetical future value
    });
    final repo = LocalSettingsRepository(PreferencesStorage());
    await repo.load();
    expect(repo.themeMode, ThemeMode.system);
  });
}
