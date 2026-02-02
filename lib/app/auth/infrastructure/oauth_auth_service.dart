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
    await _init();
  });

  Future<void> _init() async {
    try {
      final token = await _authTokenStorage.getToken();
      if (token == null) {
        _state.add(AuthState.notAuthenticated());
      } else {
        _state.add(AuthState.authenticated());
      }
    } catch (e) {
      // If token retrieval fails, treat as not authenticated
      print('Auth initialization failed: $e');
      _state.add(AuthState.notAuthenticated());
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
      print("error $e");
    }
    return AuthState.undefined();
  }

  @override
  Future<void> logout() async {
    await _authTokenStorage.clear();

    final state = AuthState.notAuthenticated();
    _state.add(state);
  }
}
