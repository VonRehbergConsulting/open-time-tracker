import 'package:flutter/material.dart';
import '/helpers/settings_storage.dart';

class SettingsProvider with ChangeNotifier {
  // Properties

  static Duration get _defaultWorkingHours {
    return const Duration(hours: 8);
  }

  SettingsStorage storage;

  Duration _workingHours = _defaultWorkingHours;

  Duration get workingHours {
    return Duration(seconds: _workingHours.inSeconds);
  }

  set workingHours(Duration value) {
    storage.saveWorkingHours(value);
    _workingHours = value;
    notifyListeners();
  }

  // Init

  SettingsProvider(this.storage) {
    _loadWorkingHours();
  }

  // Private methods

  void _loadWorkingHours() async {
    final workingHours = await storage.loadWorkingHours();
    _workingHours = workingHours ?? _defaultWorkingHours;
    notifyListeners();
  }
}
