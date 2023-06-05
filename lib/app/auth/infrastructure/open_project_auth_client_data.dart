import 'package:open_project_time_tracker/app/auth/domain/auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';

class OpenProjectAuthClientData implements AuthClientData {
  final InstanceConfigurationReadRepository _instanceConfigurationRepository;

  OpenProjectAuthClientData(
    this._instanceConfigurationRepository,
  );

  @override
  Future<String?> get clientID async =>
      _instanceConfigurationRepository.clientID;

  @override
  Future<String?> get baseUrl async => _instanceConfigurationRepository.baseUrl;

  @override
  Future<String?> get authEndpoint async {
    final url = await baseUrl;
    return '$url/oauth/authorize';
  }

  @override
  Future<String?> get tokenEndpoint async {
    final url = await baseUrl;
    return '$url/oauth/token';
  }

  @override
  Future<String?> get logoutEndpoint async => null;

  @override
  String get redirectUrl => 'openprojecttimetracker://oauth-callback';

  @override
  List<String> get scopes => ['api_v3'];
}
