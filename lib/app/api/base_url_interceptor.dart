import 'package:dio/dio.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/instance_configuration_repository.dart';

class BaseUrlInterceptor extends QueuedInterceptor {
  InstanceConfigurationRepository _instanceConfigurationRepository;

  BaseUrlInterceptor(
    this._instanceConfigurationRepository,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final baseUrl = await _instanceConfigurationRepository.baseUrl;
    if (baseUrl != null) {
      options.baseUrl = '$baseUrl/api/v3/';
    }
    super.onRequest(options, handler);
  }
}
