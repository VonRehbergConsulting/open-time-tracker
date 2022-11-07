import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

import '/services/endpoints.dart';
import '/services/token_storage.dart';
import '/env/env.dart';

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
    if (authorizationState != AuthorizationStatate.authorized) {
      authorizationState = AuthorizationStatate.authorized;
      notifyListeners();
    }
  }

  void _setUnauthorized() {
    if (authorizationState != AuthorizationStatate.unauthorized) {
      authorizationState = AuthorizationStatate.unauthorized;
      notifyListeners();
    }
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

  Future<http.Response?> _get(Uri url, {Map<String, String>? headers}) async {
    final accessToken = await tokenStorage.accessToken;
    if (accessToken == null) {
      _setUnauthorized();
      return null;
    }
    var headersWithToken = headers ?? {};
    headersWithToken.addAll({
      'Authorization': 'Bearer $accessToken',
    });
    return http.get(url, headers: headersWithToken);
  }

  Future<http.Response?> _post(Uri url,
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

  Future<http.Response?> _patch(Uri url,
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

  // Public methods

  Future<void> authorize() async {
    try {
      final response = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          Env.clientId,
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
    print('Refreshing token');
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken == null) {
      _setUnauthorized();
    }
    try {
      final result = await appAuth.token(
        TokenRequest(
          Env.clientId,
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
    } on PlatformException catch (exception) {
      print(exception);
      if (exception.code == 'token_failed') {
        print('Invalid token');
        _setUnauthorized();
      }
    } catch (e) {
      print('Can\'t refresh token');
    }
  }

  Future<void> unauthorize() async {
    tokenStorage.clear;
    authorizationState = AuthorizationStatate.unauthorized;
    notifyListeners();
  }

  Future<http.Response?> get(Uri url, {Map<String, String>? headers}) async {
    if (authorizationState == AuthorizationStatate.unauthorized) {
      return null;
    }
    final response = await _get(url, headers: headers);
    if (response?.statusCode == 401) {
      await refreshToken();
      return _get(url, headers: headers);
    } else {
      return response;
    }
  }

  Future<http.Response?> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    if (authorizationState == AuthorizationStatate.unauthorized) {
      return null;
    }
    final response =
        await _post(url, headers: headers, body: body, encoding: encoding);
    if (response?.statusCode == 401) {
      await refreshToken();
      return _post(url, headers: headers, body: body, encoding: encoding);
    } else {
      return response;
    }
  }

  Future<http.Response?> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    if (authorizationState == AuthorizationStatate.unauthorized) {
      return null;
    }
    final response =
        await _patch(url, headers: headers, body: body, encoding: encoding);
    if (response?.statusCode == 401) {
      await refreshToken();
      return _patch(url, headers: headers, body: body, encoding: encoding);
    } else {
      return response;
    }
  }
}
