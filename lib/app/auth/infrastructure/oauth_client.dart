import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
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

    // PKCE (RFC 7636). Newer OpenProject / Doorkeeper versions can
    // enforce it; older ones ignore the extra `code_challenge` /
    // `code_challenge_method` on the auth request and the extra
    // `code_verifier` on the token exchange, so sending them is
    // always safe. We use the S256 method (SHA-256 + base64url).
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _deriveCodeChallenge(codeVerifier);

    // Build authorization URL with response_type=code
    final authUrl = Uri.parse(authEndpoint)
        .replace(
          queryParameters: {
            'response_type': 'code',
            'client_id': clientID,
            'redirect_uri': redirectUrl,
            'scope': scopes,
            'code_challenge': codeChallenge,
            'code_challenge_method': 'S256',
          },
        )
        .toString();

    // Use flutter_web_auth_2 to handle the OAuth flow
    // This handles the browser launch and callback automatically
    // preferEphemeral: false ensures the session is shared with the browser
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: Uri.parse(redirectUrl).scheme,
      options: const FlutterWebAuth2Options(intentFlags: ephemeralIntentFlags),
    );

    final resultUri = Uri.parse(result);
    final code = resultUri.queryParameters['code'];

    if (code == null) throw ErrorDescription('authorization_code_null');

    // Exchange code for tokens. `code_verifier` completes the PKCE
    // handshake — required by servers that enforce PKCE, ignored by
    // those that don't.
    final tokenResp = await http.post(
      Uri.parse(tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUrl,
        'client_id': clientID,
        'code_verifier': codeVerifier,
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

  /// RFC 7636 §4.1 — 43-128 chars from the unreserved set
  /// `[A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~"`. We take 32 random
  /// bytes from a cryptographically-secure source and base64url-encode
  /// them (no padding), which yields exactly 43 URL-safe characters.
  static String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// RFC 7636 §4.2 — `BASE64URL(SHA256(ASCII(code_verifier)))` with
  /// padding stripped.
  static String _deriveCodeChallenge(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
