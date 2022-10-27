import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Properties

  FlutterSecureStorage storage;

  static const _accessTokenKey = 'accessToken';
  Future<String?> get accessToken async {
    return storage.read(key: _accessTokenKey);
  }

  static const _refreshTokenKey = 'refreshToken';
  Future<String?> get refreshToken async {
    return storage.read(key: 'refreshToken');
  }

  // Init

  TokenStorage(this.storage);

  // Public methods

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  void clear() {
    storage.deleteAll();
  }
}
