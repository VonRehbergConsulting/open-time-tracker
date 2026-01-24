import 'preferences_storage.dart';

class AppStateStorage {
  final PreferencesStorage _storage;
  final String _selectedDateKey = 'selectedDate';

  AppStateStorage(this._storage);

  Future<String?> get selectedDate async {
    return await _storage.getString(_selectedDateKey);
  }

  Future<void> setSelectedDate(String dateString) async {
    await _storage.setString(_selectedDateKey, dateString);
  }

  Future<void> clearSelectedDate() async {
    _storage.remove(_selectedDateKey);
  }
}
