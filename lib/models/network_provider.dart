import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

import '/services/endpoints.dart';
import '/services/token_storage.dart';

enum AuthorizationStatate { authorized, unauthorized, undefined }

class NetworkProvider with ChangeNotifier {
  // Properties

  FlutterAppAuth appAuth;
  TokenStorage tokenStorage;

  AuthorizationStatate authorizationState = AuthorizationStatate.undefined;

  // Init

  NetworkProvider(this.appAuth, this.tokenStorage) {
    refreshToken();
  }

  // Private methods

  void _setAuthorized() {
    authorizationState = AuthorizationStatate.authorized;
    notifyListeners();
  }

  void _setUnauthorized() {
    authorizationState = AuthorizationStatate.unauthorized;
    notifyListeners();
  }

  void _handleResponse(TokenResponse? response) {
    final accessToken = response?.accessToken;
    final refreshToken = response?.refreshToken;
    if (accessToken != null && refreshToken != null) {
      tokenStorage.updateTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      _setAuthorized();
    } else {
      print('Parsing tokens error');
      _setUnauthorized();
    }
  }

  // Public methods

  Future<void> authorize() async {
    try {
      final response = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          'OaQ4maL8tXdpS88op2pjD-lJ2P8k-2ja95Tu-2VHOds',
          'openprojecttimetracker://oauth-callback',
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: Endpoints.auth,
            tokenEndpoint: Endpoints.token,
          ),
          scopes: ['api_v3'],
          preferEphemeralSession: true,
        ),
      );
      print('Handle token response');
      _handleResponse(response);
    } catch (error) {
      print('Auth error');
      notifyListeners();
    }
  }

  Future<void> refreshToken() async {
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken == null) {
      _setUnauthorized();
    }
    try {
      final result = await appAuth.token(
        TokenRequest(
          'OaQ4maL8tXdpS88op2pjD-lJ2P8k-2ja95Tu-2VHOds',
          'openprojecttimetracker://oauth-callback',
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: Endpoints.auth,
            tokenEndpoint: Endpoints.token,
          ),
          refreshToken: refreshToken,
          scopes: ['api_v3'],
        ),
      );
      _handleResponse(result);
    } catch (error) {
      print(error);
      print('Refresh error');
      notifyListeners();
    }
  }

  Future<void> unauthorize() async {
    appAuth.endSession(
      EndSessionRequest(
        preferEphemeralSession: true,
      ),
    );
    tokenStorage.clear;
    notifyListeners();
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final accessToken = await tokenStorage.accessToken;
    if (accessToken == null) {
      _setUnauthorized();
    }
    var headersWithToken = headers ?? {};
    headersWithToken.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    return http.get(url, headers: headersWithToken);
  }

  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final accessToken = await tokenStorage.accessToken;
    if (accessToken == null) {
      _setUnauthorized();
    }
    var headersWithToken = headers ?? {};
    headersWithToken.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    return http.post(url,
        headers: headersWithToken, body: body, encoding: encoding);
  }

  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final accessToken = await tokenStorage.accessToken;
    if (accessToken == null) {
      _setUnauthorized();
    }
    var headersWithToken = headers ?? {};
    headersWithToken.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    return http.patch(url,
        headers: headersWithToken, body: body, encoding: encoding);
  }
}
