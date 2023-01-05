import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';

part 'authorization_checker_bloc.freezed.dart';

@freezed
class AuthorizationCheckerState with _$AuthorizationCheckerState {
  const factory AuthorizationCheckerState.idle() = _Idle;
}

@freezed
class AuthorizationCheckerEffect with _$AuthorizationCheckerEffect {
  const factory AuthorizationCheckerEffect.authorization() = _Authorization;
  const factory AuthorizationCheckerEffect.timeEntries() = _TimeEntries;
  const factory AuthorizationCheckerEffect.timer() = _Timer;
}

class AuthorizationCheckerBloc
    extends EffectCubit<AuthorizationCheckerState, AuthorizationCheckerEffect> {
  UserDataRepository _userDataRepository;
  AuthorizationCheckerBloc(
    this._userDataRepository,
  ) : super(AuthorizationCheckerState.idle());

  void checkState() async {
    try {
      final userID = await _userDataRepository.loadUserID();
      print('User ID: $userID');
      // TODO: check current timer
      emitEffect(const AuthorizationCheckerEffect.timeEntries());
    } catch (e) {
      print(e);
      // TODO: check if no connection
      emitEffect(const AuthorizationCheckerEffect.authorization());
    }
  }
}
