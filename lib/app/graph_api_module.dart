// removed flutter_appauth dependency; using manual OAuth flow instead
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/graph_api_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/graph_auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_auth_service.dart';

import 'api/api_client.dart';
import 'auth/domain/auth_token_storage.dart';
import 'auth/infrastructure/oauth_client.dart';
import 'auth/infrastructure/secure_auth_token_storage.dart';

@module
abstract class GraphApiModule {
  @Named('graph')
  @lazySingleton
  AuthTokenStorage authTokenStorage() => SecureAuthTokenStorage(
    const FlutterSecureStorage(),
    accessTokenKey: 'graphAccessToken',
    refreshTokenKey: 'graphRefreshToken',
  );

  @Named('graph')
  @injectable
  AuthClientData authClientData() => GraphAuthClientData();

  @Named('graph')
  @injectable
  AuthClient authClient(@Named('graph') AuthClientData authClientData) =>
      OAuthClient(authClientData);

  @Named('graph')
  @lazySingleton
  AuthService authService(
    @Named('graph') AuthClient authClient,
    @Named('graph') AuthTokenStorage authTokenStorage,
  ) => OAuthAuthService(authClient, authTokenStorage);

  @Named('graph')
  @injectable
  ApiClient apiClient(
    @Named('graph') AuthTokenStorage authTokenStorage,
    @Named('graph') AuthClient authClient,
    @Named('graph') AuthService authService,
  ) => GraphApiClient(authTokenStorage, authClient, () {
    authService.logout();
  });
}
