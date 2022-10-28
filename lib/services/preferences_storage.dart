import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  final prefs = SharedPreferences.getInstance();

  void setString(String key, String value) async {
    prefs.then((prefs) {
      prefs.setString(key, value);
    });
  }

  Future<String?> getString(String key) async {
    final storage = await prefs;
    return storage.getString(key);
  }

  void remove(String key) async {
    return prefs.then((prefs) => prefs.remove(key));
  }
}
