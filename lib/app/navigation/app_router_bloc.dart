import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
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
  final InstanceConfigurationReadRepository Function()
  _getInstanceConfigurationRepository;
  final InstancesRepository Function() _getInstancesRepository;
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _instancesSubscription;
  String? _lastActiveInstanceId;

  AppRouterBloc(
    this._getAuthService,
    this._getUserDataRepositiry,
    this._getInstanceConfigurationRepository,
    this._getInstancesRepository,
  ) : super(AppRouterState.loading());

  Future<void> init() async {
    await _authStateSubscription?.cancel();
    await _instancesSubscription?.cancel();
    if (!await _checkIsInstanceConfigured()) {
      await _getAuthService().logout();
    }
    // Seed the baseline so the very first instances snapshot doesn't
    // count as a "switch" and force an unnecessary remount on cold
    // start.
    _lastActiveInstanceId = _getInstancesRepository().current.activeInstanceId;
    _authStateSubscription = _getAuthService()
        .observeAuthState()
        .distinct()
        .listen(_onAuthServiceStateChanged, onError: addError);
    _instancesSubscription = _getInstancesRepository().observe().listen(
      _onInstancesSnapshot,
      onError: addError,
    );
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

  /// Reacts to the active OpenProject instance changing at runtime
  /// (via the app-bar switcher). The actual widget-level remount of
  /// the authorized subtree is driven by a `ValueKey` on
  /// `_KeyedAuthorizedRouter` in [AppRouter] — that key changes
  /// whenever the instances snapshot moves to a new active id and
  /// Flutter re-mounts the whole subtree accordingly, dropping every
  /// `@injectable` bloc under it (time entries list, timer, etc.) so
  /// no data cached for the previous tenant leaks into the new one.
  ///
  /// The only job left here is to **reconcile the auth state for the
  /// new instance**: if the user just switched to a tenant that has
  /// no tokens yet, we need [AuthState.notAuthenticated] to land on
  /// the observable so the router routes to the login page instead of
  /// mounting an authorized subtree that would immediately fail its
  /// first API call and land on the error screen.
  ///
  /// The switcher itself already calls [AuthService.refreshState]
  /// after `setActive`; the extra call here is safe because
  /// `observeAuthState()` is deduplicated with `.distinct()` and will
  /// not double-fire downstream handlers.
  ///
  /// Transitions involving `null` (initial load, or the last instance
  /// being removed) are ignored — they are already handled by the
  /// auth-state stream (login page / configuration screen).
  Future<void> _onInstancesSnapshot(InstancesSnapshot snapshot) async {
    final previous = _lastActiveInstanceId;
    final next = snapshot.activeInstanceId;
    _lastActiveInstanceId = next;
    if (previous == null || next == null || previous == next) {
      return;
    }
    await _getAuthService().refreshState();
  }

  @override
  Future<void> close() async {
    await _authStateSubscription?.cancel();
    await _instancesSubscription?.cancel();
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
      // If the failure was actually an auth failure the
      // AuthInterceptor's onAuthenticationFailed callback has already
      // triggered a logout — the auth-state stream will (or did) emit
      // notAuthenticated, which routes to the login page. Emitting
      // error() here would clobber that with a generic error screen,
      // which is what the user was seeing when switching to a
      // freshly-configured instance that has no tokens yet.
      final currentAuth = await _getAuthService().refreshState();
      final isAuthenticated = currentAuth.maybeWhen(
        authenticated: () => true,
        orElse: () => false,
      );
      if (isAuthenticated) {
        emit(AppRouterState.error());
      }
    }
  }
}
