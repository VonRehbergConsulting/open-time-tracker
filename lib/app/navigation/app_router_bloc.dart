import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';

import '../ui/bloc/bloc.dart';

part 'app_router_bloc.freezed.dart';

@freezed
class AppRouterState with _$AppRouterState {
  factory AppRouterState.loading() = _Loading;
  factory AppRouterState.authorized() = _Authorized;
  factory AppRouterState.unaurhorized() = _Ununthorized;
  factory AppRouterState.error() = _Error;
}

class AppRouterBloc extends Cubit<AppRouterState> {
  final AuthService Function() _getAuthService;
  final UserDataRepository Function() _getUserDataRepositiry;
  final InstanceConfigurationRepository Function()
      _getInstanceConfigurationRepository;
  StreamSubscription? _authStateSubscription;

  AppRouterBloc(
    this._getAuthService,
    this._getUserDataRepositiry,
    this._getInstanceConfigurationRepository,
  ) : super(AppRouterState.loading());

  Future<void> init() async {
    await _authStateSubscription?.cancel();
    if (!await _checkIsInstanceConfigured()) {
      await _getAuthService().logout();
    }
    _authStateSubscription = _getAuthService()
        .observeAuthState()
        .distinct()
        .listen(_onAuthServiceStateChanged, onError: addError);
  }

  Future<void> retryAuthorization() async {
    await _processAuthorized();
  }

  Future<void> _onAuthServiceStateChanged(AuthState state) async {
    state.when(
      undefined: () {
        emit(AppRouterState.loading());
      },
      authenticated: () {
        _processAuthorized();
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

  Future<bool> _checkIsInstanceConfigured() async {
    final repository = _getInstanceConfigurationRepository();
    final baseUrl = await repository.baseUrl;
    final clientId = await repository.clientID;
    return baseUrl != null && clientId != null;
  }

  Future<void> _processAuthorized() async {
    try {
      emit(AppRouterState.loading());
      await _getUserDataRepositiry().userId();
      emit(AppRouterState.authorized());
    } catch (e) {
      emit(AppRouterState.error());
    }
  }
}
