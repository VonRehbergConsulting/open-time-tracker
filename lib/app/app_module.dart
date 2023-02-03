import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/rest_api_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_auth_service.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_client.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/secure_auth_token_storage.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/instance_configuration_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/instance_configuration_repository_local.dart';

@module
abstract class AppModule {
  @lazySingleton
  AuthTokenStorage authTokenStorage() =>
      SecureAuthTokenStorage(FlutterSecureStorage());

  @lazySingleton
  AuthService authService(
          AuthClient authClient, AuthTokenStorage authTokenStorage) =>
      OAuthAuthService(
        authClient,
        authTokenStorage,
      );

  @injectable
  AuthClient authClient(
    AuthTokenStorage authTokenStorage,
    InstanceConfigurationRepository instanceConfigurationRepository,
  ) =>
      OAuthClient(
        FlutterAppAuth(),
        instanceConfigurationRepository,
      );

  @injectable
  InstanceConfigurationRepository instanceConfigurationRepository() =>
      InstanceConfigurationRepositoryLocal(
        PreferencesStorage(),
      );

  @injectable
  RestApiClient restApiClient(
    InstanceConfigurationRepository instanceConfigurationRepository,
    AuthTokenStorage authTokenStorage,
    AuthClient authClient,
    AuthService authService,
  ) =>
      RestApiClient(
        instanceConfigurationRepository,
        authTokenStorage,
        authClient,
        () {
          authService.logout();
        },
      );
}
