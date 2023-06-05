import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  final PreferencesStorage _storage;

  final String _workingHoursKey = 'workingHours';

  static Duration get _defaultWorkingHours {
    return const Duration(hours: 8);
  }

  LocalSettingsRepository(
    this._storage,
  );
  @override
  Future<Duration> get workingHours async {
    final string = await _storage.getString(_workingHoursKey);
    if (string == null) {
      return _defaultWorkingHours;
    }
    final minutes = int.tryParse(string);
    if (minutes == null) {
      return _defaultWorkingHours;
    }
    return Duration(minutes: minutes);
  }

  @override
  Future<void> setWorkingHours(Duration value) async {
    final valueString = value.inMinutes.toString();
    _storage.setString(_workingHoursKey, valueString);
  }
}
