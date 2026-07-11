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

  /// Logs out of the *current* scope only (e.g. the currently active
  /// OpenProject instance). Tokens for other configured instances stay
  /// intact. Use [logoutAll] to sign out of every configured scope.
  Future<void> logout();

  /// Logs out of every scope owned by the underlying token storage —
  /// clears access & refresh tokens for every configured instance —
  /// then emits [AuthState.notAuthenticated]. Instance configurations
  /// themselves are left in place so the user can re-authenticate
  /// against any of them from the login screen.
  Future<void> logoutAll();

  /// Re-reads the underlying credential store and re-emits the current
  /// [AuthState]. Called after external state changes (e.g. the active
  /// tenant was switched) so downstream observers land on a consistent
  /// state without needing to re-subscribe. The returned state matches
  /// what was emitted so callers can branch (e.g. probe for token
  /// validity only when authenticated).
  Future<AuthState> refreshState();
}
