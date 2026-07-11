import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:rxdart/rxdart.dart';

import '../domain/auth_service.dart';

class OAuthAuthService implements AuthService {
  final AuthClient _authClient;

  final AuthTokenStorage _authTokenStorage;

  final _state = BehaviorSubject<AuthState>();

  OAuthAuthService(this._authClient, this._authTokenStorage);

  @override
  Stream<AuthState> observeAuthState() => _state.doOnListen(() async {
    await refreshState();
  });

  /// Re-reads the token storage and re-emits the current [AuthState].
  /// Used both on first subscribe and after external state changes
  /// (e.g. the active OpenProject instance was switched).
  @override
  Future<AuthState> refreshState() async {
    try {
      final token = await _authTokenStorage.getToken();
      final state = token == null
          ? AuthState.notAuthenticated()
          : AuthState.authenticated();
      _state.add(state);
      return state;
    } catch (e) {
      debugPrint('Auth refresh failed: $e');
      final state = AuthState.notAuthenticated();
      _state.add(state);
      return state;
    }
  }

  @override
  Future<AuthState> login() async {
    try {
      final oauthToken = await _authClient.requestToken();

      await _authTokenStorage.setToken(oauthToken);

      final state = AuthState.authenticated();
      _state.add(state);
      return state;
    } catch (e) {
      debugPrint('Login failed: $e');
    }
    return AuthState.undefined();
  }

  @override
  Future<void> logout() async {
    await _authTokenStorage.clear();

    final state = AuthState.notAuthenticated();
    _state.add(state);
  }

  @override
  Future<void> logoutAll() async {
    await _authTokenStorage.clearAll();

    final state = AuthState.notAuthenticated();
    _state.add(state);
  }
}

