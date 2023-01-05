import 'package:flutter/material.dart';

import '/helpers/preferences_storage.dart';

class InstanceConfigurationProvider with ChangeNotifier {
  // Properties

  PreferencesStorage storage;

  final String _baseUrlKey = 'baseUrl';
  final String _clientIdKey = 'clientId';

  // Init

  InstanceConfigurationProvider(this.storage);

  // Public

  Future<void> setBaseUrl(String? value) async {
    if (value == null) {
      storage.remove(_baseUrlKey);
    } else {
      storage.setString(_baseUrlKey, value);
    }
    notifyListeners();
  }

  Future<String?> get baseUrl {
    return storage.getString(_baseUrlKey);
  }

  Future<void> setClientId(String? value) async {
    if (value == null) {
      storage.remove(_clientIdKey);
    } else {
      storage.setString(_clientIdKey, value);
    }
    notifyListeners();
  }

  Future<String?> get clientId {
    return storage.getString(_clientIdKey);
  }
}
