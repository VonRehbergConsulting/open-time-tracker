import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

abstract class AuthClient {
  Future<void> requestToken();

  Future<AuthToken> refreshToken(AuthToken token);

  Future<void> invalidateTokens();
}
