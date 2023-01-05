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

  Future<void> clear();
}
