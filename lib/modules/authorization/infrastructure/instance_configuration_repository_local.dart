import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/instance_configuration_repository.dart';

class InstanceConfigurationRepositoryLocal
    implements InstanceConfigurationRepository {
  PreferencesStorage _storage;

  static String _baseUrlKey = 'baseUrl';
  static String _clientIdKey = 'clientId';

  InstanceConfigurationRepositoryLocal(this._storage);

  Future<String?> get baseUrl {
    return _storage.getString(_baseUrlKey);
  }

  Future<void> setBaseUrl(String? value) async {
    if (value == null) {
      _storage.remove(_baseUrlKey);
    } else {
      _storage.setString(_baseUrlKey, value);
    }
  }

  Future<String?> get clientID {
    return _storage.getString(_clientIdKey);
  }

  Future<void> setClientID(String? value) async {
    if (value == null) {
      _storage.remove(_clientIdKey);
    } else {
      _storage.setString(_clientIdKey, value);
    }
  }
}
