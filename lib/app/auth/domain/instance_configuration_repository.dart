abstract class InstanceConfigurationReadRepository {
  Future<String?> get baseUrl;
  Future<String?> get clientID;
}

abstract class InstanceConfigurationRepository
    extends InstanceConfigurationReadRepository {
  Future<void> setBaseUrl(String? value);

  Future<void> setClientID(String? value);
}
