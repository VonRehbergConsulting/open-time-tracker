import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/ui/bloc/effect_bloc.dart';

part 'authorization_bloc.freezed.dart';

@freezed
class AuthorizationState with _$AuthorizationState {
  const factory AuthorizationState.idle({required bool canAuthorize}) = _Idle;
}

@freezed
class AuthorizationEffect with _$AuthorizationEffect {
  const factory AuthorizationEffect.error() = _Error;
}

class AuthorizationBloc
    extends EffectCubit<AuthorizationState, AuthorizationEffect> {
  final AuthService _authService;
  final InstancesRepository _instancesRepository;

  AuthorizationBloc(this._authService, this._instancesRepository)
    : super(const AuthorizationState.idle(canAuthorize: false));

  Future<void> checkInstanceConfiguration() async {
    // Ensure the instances repository has loaded its snapshot at least
    // once so [current.hasAny] reflects persisted state (including the
    // one-time migration from legacy single-instance keys).
    await _instancesRepository.load();
    emit(state.copyWith(canAuthorize: _instancesRepository.current.hasAny));
  }

  Future<void> authorize() async {
    try {
      final state = await _authService.login();
      if (state == AuthState.undefined()) {
        throw Error();
      }
    } catch (e) {
      debugPrint(e.toString());
      emitEffect(const AuthorizationEffect.error());
    }
  }
}
