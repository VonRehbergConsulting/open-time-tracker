import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

abstract class AuthClient {
  Future<AuthToken> requestToken();

  Future<AuthToken> refreshToken(AuthToken token);
}
