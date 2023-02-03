import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  Future<void> setString(String key, String value) async {
    final prefs = SharedPreferences.getInstance();
    await prefs.then((prefs) {
      prefs.setString(key, value);
    });
  }

  Future<String?> getString(String key) async {
    final prefs = SharedPreferences.getInstance();
    final storage = await prefs;
    return storage.getString(key);
  }

  void remove(String key) async {
    final prefs = SharedPreferences.getInstance();
    return prefs.then((prefs) => prefs.remove(key));
  }
}
