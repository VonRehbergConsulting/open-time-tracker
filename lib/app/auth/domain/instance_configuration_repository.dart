/// Read-only view of the currently active OpenProject instance's
/// connection details. Backed by the multi-instance repository.
abstract class InstanceConfigurationReadRepository {
  Future<String?> get baseUrl;
  Future<String?> get clientID;
}
