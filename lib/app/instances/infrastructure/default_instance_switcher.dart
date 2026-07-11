import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/instances/domain/instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/infrastructure/api_user_data_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/live_activity_coordinator.dart';

class DefaultInstanceSwitcher implements InstanceSwitcher {
  final InstancesRepository _instancesRepository;
  final TimerRepository _timerRepository;
  final AuthService _authService;
  final UserDataRepository _userDataRepository;
  final LiveActivityCoordinator _liveActivityCoordinator;

  DefaultInstanceSwitcher(
    this._instancesRepository,
    this._timerRepository,
    this._authService,
    this._userDataRepository,
    this._liveActivityCoordinator,
  );

  @override
  Future<InstanceSwitchResult> switchTo(
    String instanceId, {
    bool force = false,
  }) async {
    if (_instancesRepository.current.activeInstanceId == instanceId) {
      return InstanceSwitchResult.alreadyActive;
    }

    if (!force && await _timerRepository.isSet) {
      return InstanceSwitchResult.blockedByActiveTimer;
    }

    // If the caller forced a switch through an active timer, we still
    // need to make sure no stale timer state (or platform live activity)
    // leaks into the new instance's session.
    if (await _timerRepository.isSet) {
      try {
        await _liveActivityCoordinator.stop();
      } catch (e) {
        debugPrint('Instance switch: failed to stop live activity: $e');
      }
      try {
        await _timerRepository.reset();
      } catch (e) {
        debugPrint('Instance switch: failed to reset timer: $e');
      }
    }

    await _instancesRepository.setActive(instanceId);

    // Drop cached user data so the profile / API reflect the new tenant.
    final repo = _userDataRepository;
    if (repo is ApiUserDataRepository) {
      repo.clearCache();
    }

    // Re-check token storage under the new instance id — this will
    // push the correct AuthState (authenticated / notAuthenticated)
    // through observeAuthState() and the AppRouter reacts.
    final newState = await _authService.refreshState();

    // If the new instance appears authenticated (a token exists in
    // storage), proactively probe the API to confirm the token is
    // still valid. This is a cheap `GET /users/me`-equivalent that
    // exercises the full auth pipeline:
    //   * On 401/403 the AuthInterceptor transparently refreshes the
    //     token and retries; the user never sees the failure.
    //   * If the refresh itself fails, the interceptor invokes the
    //     onAuthenticationFailed callback which logs the user out —
    //     that emits notAuthenticated and the AppRouter routes to the
    //     login page automatically.
    //   * On any other error (network, 5xx) we swallow: the token was
    //     not proven invalid, so we keep the authenticated state and
    //     let downstream calls surface the transient failure.
    final isAuthenticated = newState.maybeWhen(
      authenticated: () => true,
      orElse: () => false,
    );
    if (isAuthenticated) {
      try {
        await _userDataRepository.userId();
      } catch (e) {
        debugPrint(
          'Instance switch: token validation probe failed for '
          '$instanceId: $e',
        );
      }
    }

    return InstanceSwitchResult.switched;
  }
}
