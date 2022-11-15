import 'preferences_storage.dart';

class SettingsStorage {
  // Properties

  PreferencesStorage storage;

  final String _workingHoursKey = 'workingHours';

  // Init

  SettingsStorage(this.storage);

  //Private methods

  void saveWorkingHours(Duration? workingHours) {
    if (workingHours == null) {
      storage.remove(_workingHoursKey);
      return;
    }
    final value = workingHours.inMinutes.toString();
    storage.setString(_workingHoursKey, value);
  }

  Future<Duration?> loadWorkingHours() async {
    final string = await storage.getString(_workingHoursKey);
    if (string == null) {
      return null;
    }
    final minutes = int.tryParse(string);
    if (minutes == null) {
      return null;
    }
    return Duration(minutes: minutes);
  }
}
