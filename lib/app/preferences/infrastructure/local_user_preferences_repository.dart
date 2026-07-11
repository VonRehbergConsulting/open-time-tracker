import 'package:open_project_time_tracker/app/preferences/domain/user_preferences_repository.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';

/// [SharedPreferences]-backed implementation of
/// [UserPreferencesRepository].
///
/// Storage keys are preserved verbatim from the previous
/// `LocalSettingsRepository` under `lib/modules/task_selection/` so
/// users don't lose their working-hours or consent state on upgrade.
class LocalUserPreferencesRepository implements UserPreferencesRepository {
  LocalUserPreferencesRepository(this._storage);

  final PreferencesStorage _storage;

  static const _workingHoursKey = 'workingHours';
  static const _analyticsConsentKey = 'analyticsConsent';

  static const Duration _defaultWorkingHours = Duration(hours: 8);

  @override
  Future<Duration> get workingHours async {
    final string = await _storage.getString(_workingHoursKey);
    if (string == null) return _defaultWorkingHours;
    final minutes = int.tryParse(string);
    if (minutes == null) return _defaultWorkingHours;
    return Duration(minutes: minutes);
  }

  @override
  Future<void> setWorkingHours(Duration value) async {
    await _storage.setString(_workingHoursKey, value.inMinutes.toString());
  }

  @override
  Future<bool?> get analyticsConsent => _storage.getBool(_analyticsConsentKey);

  @override
  Future<void> setAnalyticsConsent(bool value) async {
    await _storage.setBool(_analyticsConsentKey, value);
  }
}
