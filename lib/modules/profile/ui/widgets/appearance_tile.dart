import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/settings/domain/settings_repository.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_card.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

/// Renders the current [ThemeMode] override and lets the user change
/// it. Reads and writes [SettingsRepository] directly (no bloc) — the
/// state is a single enum and the write path is trivial.
class AppearanceTile extends StatefulWidget {
  const AppearanceTile({super.key});

  @override
  State<AppearanceTile> createState() => _AppearanceTileState();
}

class _AppearanceTileState extends State<AppearanceTile> {
  late final SettingsRepository _settings;
  late final Stream<ThemeMode> _stream;

  @override
  void initState() {
    super.initState();
    _settings = inject<SettingsRepository>();
    _stream = _settings.observeThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<ThemeMode>(
      stream: _stream,
      initialData: _settings.themeMode,
      builder: (context, snap) {
        final mode = snap.data ?? ThemeMode.system;
        return ConfiguredCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _iconForMode(mode),
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(_labelForMode(context, mode)),
                  subtitle: Text(l10n.appearance_description),
                ),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.appearance_theme_system),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.appearance_theme_light),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.appearance_theme_dark),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (selection) {
                    // The BehaviorSubject.add() inside setThemeMode()
                    // is synchronous, so the UI updates on the next
                    // frame. The persisted write is deferred; wrap in
                    // unawaited() to make the fire-and-forget intent
                    // explicit for linters.
                    unawaited(_settings.setThemeMode(selection.first));
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _labelForMode(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case ThemeMode.system:
        return l10n.appearance_theme_system;
      case ThemeMode.light:
        return l10n.appearance_theme_light;
      case ThemeMode.dark:
        return l10n.appearance_theme_dark;
    }
  }
}
