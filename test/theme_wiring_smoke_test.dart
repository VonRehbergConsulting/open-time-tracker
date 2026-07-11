import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_project_time_tracker/app/settings/infrastructure/local_settings_repository.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/app/ui/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke test for the `MyApp` theme wiring: the `MaterialApp`'s
/// `themeMode` must follow `SettingsRepository.observeThemeMode()`
/// so a tap in the profile page immediately re-tints the whole app.
///
/// We don't pump `MyApp` itself — that would need the full DI graph
/// (AppRouter, AppRouterBloc, auth stack, …). Instead we replicate
/// the exact `StreamBuilder<ThemeMode>` shape from `MyApp.build` and
/// verify the contract end-to-end against the real repository.
Widget _themedApp(LocalSettingsRepository settings) {
  return StreamBuilder<ThemeMode>(
    stream: settings.observeThemeMode(),
    initialData: settings.themeMode,
    builder: (context, snap) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: snap.data ?? ThemeMode.system,
        home: const SizedBox.shrink(),
      );
    },
  );
}

MaterialApp _findMaterialApp(WidgetTester tester) {
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MaterialApp starts in the persisted themeMode',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.themeMode': 'dark',
    });
    final settings = LocalSettingsRepository(PreferencesStorage());
    await settings.load();

    await tester.pumpWidget(_themedApp(settings));

    expect(_findMaterialApp(tester).themeMode, ThemeMode.dark);
  });

  testWidgets('MaterialApp reflects setThemeMode() live', (tester) async {
    final settings = LocalSettingsRepository(PreferencesStorage());
    await settings.load();

    await tester.pumpWidget(_themedApp(settings));
    expect(_findMaterialApp(tester).themeMode, ThemeMode.system);

    await settings.setThemeMode(ThemeMode.dark);
    await tester.pump();
    expect(_findMaterialApp(tester).themeMode, ThemeMode.dark);

    await settings.setThemeMode(ThemeMode.light);
    await tester.pump();
    expect(_findMaterialApp(tester).themeMode, ThemeMode.light);
  });
}
