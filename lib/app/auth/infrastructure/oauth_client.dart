import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

import '../domain/auth_client.dart';

class OAuthClient implements AuthClient {
  final FlutterAppAuth _flutterAppAuth;
  final AuthClientData _authClientData;

  OAuthClient(
    this._flutterAppAuth,
    this._authClientData,
  );

  @override
  Future<AuthToken> requestToken() async {
    final clientID = await _authClientData.clientID;
    final redirectUrl = _authClientData.redirectUrl;
    final authEndpoint = await _authClientData.authEndpoint;
    final tokenEndpoint = await _authClientData.tokenEndpoint;
    final logoutEndpoint = await _authClientData.logoutEndpoint;
    if (tokenEndpoint == null || authEndpoint == null || clientID == null) {
      throw ErrorDescription('invalid_instance');
    }
    final serviceConfiguration = AuthorizationServiceConfiguration(
      authorizationEndpoint: authEndpoint,
      tokenEndpoint: tokenEndpoint,
      endSessionEndpoint: logoutEndpoint,
    );
    final scopes = _authClientData.scopes;
    try {
      final response = await _flutterAppAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientID,
          redirectUrl,
          serviceConfiguration: serviceConfiguration,
          scopes: scopes,
          // preferEphemeralSession: true,
        ),
      );
      return _parseToken(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final clientID = await _authClientData.clientID;
      final redirectUrl = _authClientData.redirectUrl;
      final authEndpoint = await _authClientData.authEndpoint;
      final tokenEndpoint = await _authClientData.tokenEndpoint;
      final logoutEndpoint = await _authClientData.logoutEndpoint;
      if (tokenEndpoint == null || authEndpoint == null || clientID == null) {
        throw ErrorDescription('invalid_instance');
      }
      final serviceConfiguration = AuthorizationServiceConfiguration(
        authorizationEndpoint: authEndpoint,
        tokenEndpoint: tokenEndpoint,
        endSessionEndpoint: logoutEndpoint,
      );
      final scopes = _authClientData.scopes;
      final response = await _flutterAppAuth.token(
        TokenRequest(
          clientID,
          redirectUrl,
          serviceConfiguration: serviceConfiguration,
          refreshToken: token.refreshToken,
          scopes: scopes,
        ),
      );
      return _parseToken(response);
    } catch (e) {
      rethrow;
    }
  }

  AuthToken _parseToken(TokenResponse? response) {
    final accessToken = response?.accessToken;
    final refreshToken = response?.refreshToken;
    if (accessToken == null || refreshToken == null) {
      throw ErrorDescription('tokens_are_null');
    }
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
