import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

class SecureAuthTokenStorage implements AuthTokenStorage {
  FlutterSecureStorage _storage;

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  AuthToken? _current;
  @override
  AuthToken? get current => _current?.copyWith();

  SecureAuthTokenStorage(this._storage);

  @override
  Future<void> clear() async {
    // TODO: delete only tokens
    await _storage.deleteAll();
  }

  @override
  Future<AuthToken?> getToken() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    return accessToken == null || refreshToken == null
        ? null
        : AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
  }

  @override
  Future<void> setToken(AuthToken token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
  }
}
