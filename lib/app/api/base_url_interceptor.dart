import 'package:dio/dio.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';

class BaseUrlInterceptor extends QueuedInterceptor {
  final InstanceConfigurationReadRepository
      _instanceConfigurationReadRepository;

  BaseUrlInterceptor(
    this._instanceConfigurationReadRepository,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final baseUrl = await _instanceConfigurationReadRepository.baseUrl;
    if (baseUrl != null) {
      options.baseUrl = '$baseUrl/api/v3/';
    }
    super.onRequest(options, handler);
  }
}
