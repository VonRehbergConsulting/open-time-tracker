import 'package:flutter/widgets.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/instance_configuration_repository.dart';

class OAuthClient implements AuthClient {
  FlutterAppAuth _flutterAppAuth;
  AuthTokenStorage _authTokenStorage;
  InstanceConfigurationRepository _instanceConfigurationRepository;

  OAuthClient(
    this._flutterAppAuth,
    this._authTokenStorage,
    this._instanceConfigurationRepository,
  );

  @override
  Future<AuthToken> requestToken() async {
    try {
      final baseUrl = await _instanceConfigurationRepository.baseUrl;
      final clientID = await _instanceConfigurationRepository.clientID;
      if (baseUrl == null || clientID == null) {
        throw ErrorDescription('invalid_instance');
      }
      bool isValidProtocol =
          baseUrl.contains('http://') || baseUrl.contains('https://');
      if (Uri.tryParse(baseUrl) == null || !isValidProtocol) {
        throw ErrorDescription('invalid_url');
      }
      final authEndpoint = '$baseUrl/oauth/authorize';
      final tokenEndpoint = '$baseUrl/oauth/token';
      final response = await _flutterAppAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientID,
          'openprojecttimetracker://oauth-callback',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: authEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          scopes: ['api_v3'],
          preferEphemeralSession: true,
        ),
      );
      final accessToken = response?.accessToken;
      final refreshToken = response?.refreshToken;
      if (accessToken == null || refreshToken == null) {
        throw ErrorDescription('tokens_are_null');
      }
      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final baseUrl = await _instanceConfigurationRepository.baseUrl;
      final clientID = await _instanceConfigurationRepository.clientID;
      if (baseUrl == null || clientID == null) {
        throw ErrorDescription('invalid_instance');
      }
      bool isValidProtocol =
          baseUrl.contains('http://') || baseUrl.contains('https://');
      if (Uri.tryParse(baseUrl) == null || !isValidProtocol) {
        throw ErrorDescription('invalid_url');
      }
      final authEndpoint = '$baseUrl/oauth/authorize';
      final tokenEndpoint = '$baseUrl/oauth/token';
      final response = await _flutterAppAuth.token(
        TokenRequest(
          clientID,
          'openprojecttimetracker://oauth-callback',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: authEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          refreshToken: token.refreshToken,
          scopes: ['api_v3'],
        ),
      );
      final accessToken = response?.accessToken;
      final refreshToken = response?.refreshToken;
      if (accessToken == null || refreshToken == null) {
        throw ErrorDescription('tokens_are_null');
      }
      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> invalidateTokens() async {
    await _authTokenStorage.clear();
  }
}
