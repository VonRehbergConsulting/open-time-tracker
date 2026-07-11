import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/instances/domain/instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/instances/domain/open_project_instance.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';

part 'instances_list_bloc.freezed.dart';

@freezed
class InstancesListState with _$InstancesListState {
  const factory InstancesListState.idle({
    required List<OpenProjectInstance> instances,
    required String? activeInstanceId,
  }) = _Idle;
}

@freezed
class InstancesListEffect with _$InstancesListEffect {
  /// The user picked an instance while a timer is running for the
  /// currently active one. The UI must prompt the user to save or
  /// discard before retrying.
  const factory InstancesListEffect.switchBlockedByActiveTimer({
    required String targetInstanceId,
  }) = _SwitchBlockedByActiveTimer;

  const factory InstancesListEffect.error() = _Error;
}

class InstancesListBloc
    extends EffectCubit<InstancesListState, InstancesListEffect> {
  final InstancesRepository _instancesRepository;
  final InstanceSwitcher _instanceSwitcher;

  StreamSubscription<InstancesSnapshot>? _subscription;

  InstancesListBloc(
    this._instancesRepository,
    this._instanceSwitcher,
  ) : super(
        const InstancesListState.idle(instances: [], activeInstanceId: null),
      );

  Future<void> init() async {
    await _instancesRepository.load();
    await _subscription?.cancel();
    _subscription = _instancesRepository
        .observe()
        .listen(_onSnapshot, onError: addError);
  }

  void _onSnapshot(InstancesSnapshot snapshot) {
    if (isClosed) return;
    emit(
      InstancesListState.idle(
        instances: snapshot.instances,
        activeInstanceId: snapshot.activeInstanceId,
      ),
    );
  }

  /// Attempts to make [instanceId] active. If a timer is running, emits
  /// [InstancesListEffect.switchBlockedByActiveTimer] instead so the UI
  /// can present the save-or-discard prompt.
  Future<void> selectInstance(String instanceId) async {
    try {
      final result = await _instanceSwitcher.switchTo(instanceId);
      if (result == InstanceSwitchResult.blockedByActiveTimer) {
        emitEffect(
          InstancesListEffect.switchBlockedByActiveTimer(
            targetInstanceId: instanceId,
          ),
        );
      }
    } catch (e) {
      emitEffect(const InstancesListEffect.error());
    }
  }

  /// Forces the switch even if a timer is active. Called by the UI
  /// after the user has resolved the timer (saved or discarded).
  Future<void> forceSelectInstance(String instanceId) async {
    try {
      await _instanceSwitcher.switchTo(instanceId, force: true);
    } catch (e) {
      emitEffect(const InstancesListEffect.error());
    }
  }

  Future<void> removeInstance(String instanceId) async {
    try {
      final wasActive =
          _instancesRepository.current.activeInstanceId == instanceId;
      await _instancesRepository.remove(instanceId);
      // If the removed instance was the active one, the active id was
      // reset to another instance (or cleared) by the repository. In
      // either case the auth state needs to be re-checked so downstream
      // routing reflects the new active tenant.
      if (wasActive) {
        // Reuse the switcher for the reset flow: switching to the new
        // active (or to null) clears caches and refreshes auth state.
        final next = _instancesRepository.current.activeInstanceId;
        if (next != null) {
          await _instanceSwitcher.switchTo(next, force: true);
        }
      }
    } catch (e) {
      emitEffect(const InstancesListEffect.error());
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
