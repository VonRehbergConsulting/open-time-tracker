import 'dart:convert';
// no local servers used; using uni_links for deep-link capture

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart' show deepLinkSvc;
import 'package:open_project_time_tracker/app/auth/domain/auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

import '../domain/auth_client.dart';

class OAuthClient implements AuthClient {
  final AuthClientData _authClientData;

  OAuthClient(this._authClientData);

  @override
  Future<AuthToken> requestToken() async {
    final clientID = await _authClientData.clientID;
    final redirectUrl = _authClientData.redirectUrl;
    final authEndpoint = await _authClientData.authEndpoint;
    final tokenEndpoint = await _authClientData.tokenEndpoint;
    if (tokenEndpoint == null || authEndpoint == null || clientID == null) {
      throw ErrorDescription('invalid_instance');
    }
    final scopes = _authClientData.scopes.join(' ');

    // Build authorization URL with response_type=code
    final authUrl = Uri.parse(authEndpoint)
        .replace(
          queryParameters: {
            'response_type': 'code',
            'client_id': clientID,
            'redirect_uri': redirectUrl,
            'scope': scopes,
          },
        )
        .toString();

    // Open system browser to start authorization
    if (!await launchUrl(
      Uri.parse(authUrl),
      mode: LaunchMode.externalApplication,
    )) {
      throw ErrorDescription('could_not_launch_browser');
    }

    // Wait for the redirect containing the authorization code.
    // We only support custom-scheme deep-links captured with `uni_links`.
    final uri = Uri.tryParse(redirectUrl);
    if (uri == null) throw ErrorDescription('invalid_redirect');
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      throw ErrorDescription('http_loopback_redirects_not_supported');
    }

    // await next deep link using the app's DeepLinkService, which handles cold-start and runtime links
    final incoming = await deepLinkSvc.awaitLink();
    if (incoming == null) throw ErrorDescription('deep_link_timeout_or_error');
    final incomingUri = Uri.parse(incoming);
    final code = incomingUri.queryParameters['code'];

    if (code == null) throw ErrorDescription('authorization_code_null');

    // Exchange code for tokens
    final tokenResp = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUrl,
        'client_id': clientID,
      },
    );

    if (tokenResp.statusCode < 200 || tokenResp.statusCode >= 300) {
      throw ErrorDescription('token_exchange_failed:${tokenResp.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(tokenResp.body);
    final accessToken = json['access_token'] as String?;
    final refreshToken = json['refresh_token'] as String?;
    if (accessToken == null || refreshToken == null)
      throw ErrorDescription('tokens_are_null');
    return AuthToken(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<AuthToken> refreshToken(AuthToken token) async {
    try {
      final clientID = await _authClientData.clientID;
      final authEndpoint = await _authClientData.authEndpoint;
      final tokenEndpoint = await _authClientData.tokenEndpoint;
      if (tokenEndpoint == null || authEndpoint == null || clientID == null) {
        throw ErrorDescription('invalid_instance');
      }
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': token.refreshToken,
          'client_id': clientID,
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ErrorDescription('token_refresh_failed:${response.statusCode}');
      }
      final Map<String, dynamic> json = jsonDecode(response.body);
      final accessToken = json['access_token'] as String?;
      final refreshToken = json['refresh_token'] as String?;
      if (accessToken == null || refreshToken == null)
        throw ErrorDescription('tokens_are_null');
      return AuthToken(accessToken: accessToken, refreshToken: refreshToken);
    } catch (e) {
      rethrow;
    }
  }
}
