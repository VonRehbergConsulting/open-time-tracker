import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';

/// Adapter exposing the currently active [InstancesRepository] instance's
/// connection details behind the legacy [InstanceConfigurationReadRepository]
/// interface, so existing consumers (API client, auth client data, …) keep
/// working transparently after the multi-instance migration.
class ActiveInstanceConfigurationRepository
    implements InstanceConfigurationReadRepository {
  final InstancesRepository _instancesRepository;

  ActiveInstanceConfigurationRepository(this._instancesRepository);

  @override
  Future<String?> get baseUrl async {
    await _instancesRepository.load();
    return _instancesRepository.current.activeInstance?.baseUrl;
  }

  @override
  Future<String?> get clientID async {
    await _instancesRepository.load();
    return _instancesRepository.current.activeInstance?.clientId;
  }
}
