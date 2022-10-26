class TokenStorage {
  // Properties

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken {
    return _accessToken;
  }

  String? get refreshToken {
    return _refreshToken;
  }

  // Public methods

  void updateTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
  }
}
