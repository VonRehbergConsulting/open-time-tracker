import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token_storage.freezed.dart';

@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    required String refreshToken,
  }) = _AuthToken;
}

abstract class AuthTokenStorage {
  AuthToken? get current;

  Future<AuthToken?> getToken();

  Future<void> setToken(AuthToken token);

  /// Clears the tokens for the *current* scope (e.g. the currently
  /// active OpenProject instance). Tokens for other scopes are left
  /// untouched — use [clearAll] to wipe every scope owned by this
  /// storage instance.
  Future<void> clear();

  /// Clears every token owned by this storage instance across all
  /// scopes (per-instance keyed and legacy unscoped alike). For
  /// single-scope storages this behaves like [clear].
  Future<void> clearAll();
}
