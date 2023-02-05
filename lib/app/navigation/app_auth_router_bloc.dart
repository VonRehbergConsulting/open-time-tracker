import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';

import '../ui/bloc/bloc.dart';

part 'app_auth_router_bloc.freezed.dart';

@freezed
class AppRouterState with _$AppRouterState {
  factory AppRouterState.loading() = _Loading;
  factory AppRouterState.authorized() = _Authorized;
  factory AppRouterState.unaurhorized() = _Ununthorized;
}

class AppRouterBloc extends Cubit<AppRouterState> {
  final AuthService Function() _getAuthService;
  final UserDataRepository Function() _getUserDataRepositiry;
  StreamSubscription? _authStateSubscription;

  AppRouterBloc(this._getAuthService, this._getUserDataRepositiry)
      : super(AppRouterState.loading());

  Future<void> init() async {
    await _authStateSubscription?.cancel();
    _authStateSubscription = _getAuthService()
        .observeAuthState()
        .distinct()
        .listen(_onAuthServiceStateChanged, onError: addError);
  }

  Future<void> _onAuthServiceStateChanged(AuthState state) async {
    state.when(
      undefined: () {
        emit(AppRouterState.loading());
      },
      authenticated: () async {
        try {
          emit(AppRouterState.loading());
          await _getUserDataRepositiry().loadUserID();
          emit(AppRouterState.authorized());
        } catch (e) {
          print(e);
        }
      },
      notAuthenticated: () {
        emit(AppRouterState.unaurhorized());
      },
    );
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    return super.close();
  }
}
