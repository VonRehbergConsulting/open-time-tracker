import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/app/api/auth_interceptor.dart';
import 'package:open_project_time_tracker/app/api/base_url_interceptor.dart';
import 'package:open_project_time_tracker/app/api/logging_interceptor.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/instance_configuration_repository.dart';

class RestApiClient {
  final void Function()? onAuthenticationFailed;

  final InstanceConfigurationRepository _instanceConfigurationRepository;
  final AuthTokenStorage _authTokenStorage;
  final AuthClient _authClient;

  RestApiClient(
    this._instanceConfigurationRepository,
    this._authTokenStorage,
    this._authClient,
    this.onAuthenticationFailed,
  );

  Dio get dio {
    final dio = Dio();

    dio.interceptors.addAll(
      [
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) async {
            options.connectTimeout = 15000;
            options.receiveTimeout = 15000;
            return handler.next(options);
          },
        ),
        BaseUrlInterceptor(
          _instanceConfigurationRepository,
        ),
        AuthInterceptor(
          dio,
          _authTokenStorage,
          _authClient,
          onAuthenticationFailed,
        ),
        if (!kReleaseMode) // if debug
          LoggingInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (obj) => print("[HTTP], ${obj.toString()}"),
          ),
      ],
    );
    return dio;
  }
}
