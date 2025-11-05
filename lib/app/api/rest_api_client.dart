import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/app/api/auth_interceptor.dart';
import 'package:open_project_time_tracker/app/api/base_url_interceptor.dart';
import 'package:open_project_time_tracker/app/api/logging_interceptor.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';

import 'api_client.dart';

class RestApiClient implements ApiClient {
  final void Function()? onAuthenticationFailed;

  final InstanceConfigurationReadRepository
  _instanceConfigurationReadRepository;
  final AuthTokenStorage _authTokenStorage;
  final AuthClient _authClient;

  RestApiClient(
    this._instanceConfigurationReadRepository,
    this._authTokenStorage,
    this._authClient,
    this.onAuthenticationFailed,
  );

  @override
  Dio get dio {
    final dio = Dio();

    // Ensure we use platform default root certificates and do not bypass TLS validation.
    // On non-web platforms, configure the IO adapter explicitly to use the default
    // SecurityContext and avoid setting any badCertificateCallback.
    if (!kIsWeb) {
      final ioAdapter = IOHttpClientAdapter();
      ioAdapter.createHttpClient = () {
        // Create default HttpClient which uses platform root certificates.
        return HttpClient();
      };
      dio.httpClientAdapter = ioAdapter;
    }

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              options.connectTimeout = const Duration(seconds: 5);
              options.receiveTimeout = const Duration(seconds: 3);
              return handler.next(options);
            },
      ),
      BaseUrlInterceptor(_instanceConfigurationReadRepository),
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
    ]);
    return dio;
  }
}
