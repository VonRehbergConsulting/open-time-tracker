import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/ui/bloc/effect_bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/instance_configuration_repository.dart';

part 'authorization_bloc.freezed.dart';

@freezed
class AuthorizationState with _$AuthorizationState {
  const factory AuthorizationState.idle({
    required bool canAuthorize,
  }) = _Idle;
}

@freezed
class AuthorizationEffect with _$AuthorizationEffect {
  const factory AuthorizationEffect.complete() = _Complete;
  const factory AuthorizationEffect.error({
    required String message,
  }) = _Error;
}

class AuthorizationBloc
    extends EffectCubit<AuthorizationState, AuthorizationEffect> {
  InstanceConfigurationRepository _instanceConfigurationRepository;
  AuthClient _authClient;

  AuthorizationBloc(
    this._instanceConfigurationRepository,
    this._authClient,
  ) : super(AuthorizationState.idle(
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
      await _authClient.requestToken();
      emitEffect(AuthorizationEffect.complete());
    } catch (e) {
      emitEffect(AuthorizationEffect.error(
        message: 'Something went wrong',
      ));
    }
  }
}
