import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/ui/bloc/effect_bloc.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';

part 'authorization_bloc.freezed.dart';

@freezed
class AuthorizationState with _$AuthorizationState {
  const factory AuthorizationState.idle({
    required bool canAuthorize,
  }) = _Idle;
}

@freezed
class AuthorizationEffect with _$AuthorizationEffect {
  const factory AuthorizationEffect.error() = _Error;
}

class AuthorizationBloc
    extends EffectCubit<AuthorizationState, AuthorizationEffect> {
  final InstanceConfigurationReadRepository _instanceConfigurationRepository;
  final AuthService _authService;

  AuthorizationBloc(
    this._instanceConfigurationRepository,
    this._authService,
  ) : super(const AuthorizationState.idle(
          canAuthorize: false,
        ));

  Future<void> checkInstanceConfiguration() async {
    final baseUrl = await _instanceConfigurationRepository.baseUrl;
    final clientID = await _instanceConfigurationRepository.clientID;
    final isConfigured = baseUrl != null &&
        baseUrl.isNotEmpty &&
        clientID != null &&
        clientID.isNotEmpty;
    emit(state.copyWith(
      canAuthorize: isConfigured,
    ));
  }

  Future<void> authorize() async {
    try {
      final state = await _authService.login();
      if (state == AuthState.undefined()) {
        throw Error();
      }
    } catch (e) {
      print(e);
      emitEffect(const AuthorizationEffect.error());
    }
  }
}
