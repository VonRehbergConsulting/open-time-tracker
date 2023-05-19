import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

class SecureAuthTokenStorage implements AuthTokenStorage {
  FlutterSecureStorage _storage;

  final String accessTokenKey;
  final String refreshTokenKey;

  AuthToken? _current;
  @override
  AuthToken? get current => _current?.copyWith();

  SecureAuthTokenStorage(
    this._storage, {
    required this.accessTokenKey,
    required this.refreshTokenKey,
  });

  @override
  Future<void> clear() async {
    await _storage.write(key: accessTokenKey, value: null);
    await _storage.write(key: refreshTokenKey, value: null);
  }

  @override
  Future<AuthToken?> getToken() async {
    final accessToken = await _storage.read(key: accessTokenKey);
    final refreshToken = await _storage.read(key: refreshTokenKey);
    return accessToken == null || refreshToken == null
        ? null
        : AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
  }

  @override
  Future<void> setToken(AuthToken token) async {
    await _storage.write(key: accessTokenKey, value: token.accessToken);
    await _storage.write(key: refreshTokenKey, value: token.refreshToken);
  }
}
