abstract class InstanceConfigurationRepository {
  Future<String?> get baseUrl;
  Future<void> setBaseUrl(String? value);

  Future<String?> get clientID;
  Future<void> setClientID(String? value);
}
