import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/app/api/auth_interceptor.dart';
import 'package:open_project_time_tracker/app/api/logging_interceptor.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

import 'api_client.dart';

class GraphApiClient implements ApiClient {
  final void Function()? onAuthenticationFailed;

  final AuthTokenStorage _authTokenStorage;
  final AuthClient _authClient;

  GraphApiClient(
    this._authTokenStorage,
    this._authClient,
    this.onAuthenticationFailed,
  );

  @override
  Dio get dio {
    final dio = Dio();

    dio.interceptors.addAll(
      [
        InterceptorsWrapper(
          onRequest: (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) async {
            options.connectTimeout = const Duration(seconds: 5);
            options.receiveTimeout = const Duration(seconds: 3);
            options.baseUrl = 'https://graph.microsoft.com';
            return handler.next(options);
          },
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
