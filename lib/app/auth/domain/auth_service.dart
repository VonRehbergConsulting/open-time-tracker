import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_service.freezed.dart';

enum AuthenticationError {
  invalidCredentials,
  io,
}

@freezed
class AuthState with _$AuthState {
  factory AuthState.undefined() = _Undefined;
  factory AuthState.authenticated() = _Authenticated;
  factory AuthState.notAuthenticated() = _NotAuthenticated;

  AuthState._();
}

abstract class AuthService {
  Stream<AuthState> observeAuthState();

  Future<AuthState> login();

  Future<void> logout();
}
