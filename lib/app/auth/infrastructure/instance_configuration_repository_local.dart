import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';

class InstanceConfigurationRepositoryLocal
    implements InstanceConfigurationRepository {
  PreferencesStorage _storage;

  final String baseUrlKey;
  final String clientIdKey;

  InstanceConfigurationRepositoryLocal(
    this._storage, {
    required this.baseUrlKey,
    required this.clientIdKey,
  });

  Future<String?> get baseUrl {
    return _storage.getString(baseUrlKey);
  }

  Future<void> setBaseUrl(String? value) async {
    if (value == null) {
      _storage.remove(baseUrlKey);
    } else {
      await _storage.setString(baseUrlKey, value);
    }
  }

  Future<String?> get clientID {
    return _storage.getString(clientIdKey);
  }

  Future<void> setClientID(String? value) async {
    if (value == null) {
      _storage.remove(clientIdKey);
    } else {
      await _storage.setString(clientIdKey, value);
    }
  }
}
