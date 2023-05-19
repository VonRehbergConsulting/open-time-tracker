import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/rest_api_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_auth_service.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_client.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/open_project_auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/secure_auth_token_storage.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/instance_configuration_repository_local.dart';

import 'api/api_client.dart';
import 'auth/domain/auth_client_data.dart';

@module
abstract class AppModule {
  @Named('openProject')
  @lazySingleton
  AuthTokenStorage authTokenStorage() => SecureAuthTokenStorage(
        FlutterSecureStorage(),
        accessTokenKey: 'accessToken',
        refreshTokenKey: 'refreshToken',
      );

  @Named('openProject')
  @lazySingleton
  AuthService authService(
    @Named('openProject') AuthClient authClient,
    @Named('openProject') AuthTokenStorage authTokenStorage,
  ) =>
      OAuthAuthService(
        authClient,
        authTokenStorage,
      );

  @Named('openProject')
  @injectable
  AuthClientData authClientData(
    @Named('openProject')
        InstanceConfigurationRepository instanceConfigurationRepository,
  ) =>
      OpenProjectAuthClientData(
        instanceConfigurationRepository,
      );

  @Named('openProject')
  @injectable
  AuthClient authClient(
    @Named('openProject') AuthTokenStorage authTokenStorage,
    @Named('openProject') AuthClientData authClientData,
  ) =>
      OAuthClient(
        FlutterAppAuth(),
        authClientData,
      );

  @Named('openProject')
  @injectable
  InstanceConfigurationReadRepository instanceConfigurationReadRepository() =>
      InstanceConfigurationRepositoryLocal(
        PreferencesStorage(),
        baseUrlKey: 'baseUrl',
        clientIdKey: 'clientId',
      );

  @Named('openProject')
  @injectable
  InstanceConfigurationRepository instanceConfigurationRepository() =>
      InstanceConfigurationRepositoryLocal(
        PreferencesStorage(),
        baseUrlKey: 'baseUrl',
        clientIdKey: 'clientId',
      );

  @Named('openProject')
  @injectable
  ApiClient apiClient(
    @Named('openProject')
        InstanceConfigurationReadRepository instanceConfigurationRepository,
    @Named('openProject') AuthTokenStorage authTokenStorage,
    @Named('openProject') AuthClient authClient,
    @Named('openProject') AuthService authService,
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
