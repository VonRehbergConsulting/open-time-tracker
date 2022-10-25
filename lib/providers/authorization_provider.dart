import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class AuthorizationProvider extends ChangeNotifier {
  FlutterAppAuth appAuth = const FlutterAppAuth();

  Future<void> authorize() async {
    try {
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest('OaQ4maL8tXdpS88op2pjD-lJ2P8k-2ja95Tu-2VHOds',
            'openprojecttimetracker://oauth-callback',
            serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: 'http://localhost:8080/oauth/authorize',
              tokenEndpoint: 'http://localhost:8080/oauth/token',
            ),
            scopes: ['api_v3']),
      );
      print(result?.refreshToken);
      notifyListeners();
    } catch (error) {
      notifyListeners();
    }
  }
}
