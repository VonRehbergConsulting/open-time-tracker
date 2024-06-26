import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';

part 'instance_configuration_bloc.freezed.dart';

@freezed
class InstanceConfigurationState with _$InstanceConfigurationState {
  const factory InstanceConfigurationState.idle() = _Idle;
}

@freezed
class InstanceConfigurationEffect with _$InstanceConfigurationEffect {
  const factory InstanceConfigurationEffect.complete() = _Complete;
  const factory InstanceConfigurationEffect.update({
    required String baseUrl,
    required String clientID,
  }) = _Update;
  const factory InstanceConfigurationEffect.invalidUrl() = _InvalidUrl;
}

class InstanceConfigurationBloc extends EffectCubit<InstanceConfigurationState,
    InstanceConfigurationEffect> {
  final InstanceConfigurationRepository _instanceConfigurationRepository;

  InstanceConfigurationBloc(
    this._instanceConfigurationRepository,
  ) : super(const InstanceConfigurationState.idle()) {
    loadData();
  }

  Future<void> loadData() async {
    final baseUrl = await _instanceConfigurationRepository.baseUrl ?? '';
    final clientID = await _instanceConfigurationRepository.clientID ?? '';
    emitEffect(InstanceConfigurationEffect.update(
      baseUrl: baseUrl,
      clientID: clientID,
    ));
  }

  Future<void> saveData(
    String baseUrl,
    String cliendID,
  ) async {
    if (_validateUrl(baseUrl)) {
      await _instanceConfigurationRepository.setBaseUrl(baseUrl);
      await _instanceConfigurationRepository.setClientID(cliendID);
      emitEffect(const InstanceConfigurationEffect.complete());
    } else {
      emitEffect(const InstanceConfigurationEffect.invalidUrl());
    }
  }

  bool _validateUrl(String urlString) {
    try {
      final url = Uri.parse(urlString);
      return url.host.isNotEmpty &&
          (url.scheme == 'http' || url.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
