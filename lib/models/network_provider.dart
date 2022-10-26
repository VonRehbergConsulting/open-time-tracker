import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:open_project_time_tracker/services/endpoints.dart';

import 'package:open_project_time_tracker/services/token_storage.dart';

class NetworkProvider with ChangeNotifier {
  // Properties

  FlutterAppAuth appAuth;
  TokenStorage tokenStorage;

  bool get isAuthorized {
    return tokenStorage.accessToken != null;
  }

  // Init

  NetworkProvider(this.appAuth, this.tokenStorage);

  // Private methods

  void _handleResponse(TokenResponse? response) {
    final accessToken = response?.accessToken;
    final refreshToken = response?.refreshToken;
    if (accessToken != null && refreshToken != null) {
      tokenStorage.updateTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      notifyListeners();
    } else {
      print('Parsing tokens error');
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
    try {
      final result = await appAuth.token(
        TokenRequest(
          'OaQ4maL8tXdpS88op2pjD-lJ2P8k-2ja95Tu-2VHOds',
          'openprojecttimetracker://oauth-callback',
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: Endpoints.auth,
            tokenEndpoint: Endpoints.token,
          ),
          refreshToken: tokenStorage.refreshToken,
          scopes: ['api_v3'],
        ),
      );
      _handleResponse(result);
    } catch (error) {
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

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    var headersWithToken = headers ?? {};
    headersWithToken.addAll({
      'Authorization': 'Bearer ${tokenStorage.accessToken}',
    });
    return http.get(url, headers: headersWithToken);
  }
}
