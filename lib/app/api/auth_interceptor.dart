import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final void Function()? onAuthetnicationFailed;

  final Dio dio;
  final AuthTokenStorage _tokenStorage;
  final AuthClient _authClient;

  AuthInterceptor(
    this.dio,
    this._tokenStorage,
    this._authClient,
    this.onAuthetnicationFailed,
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();

    if (token != null) {
      options.headers.addAll({
        "Authorization": "Bearer ${token.accessToken}",
      });
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == HttpStatus.unauthorized ||
        err.response?.statusCode == HttpStatus.forbidden) {
      print("Authetnication error - unauthorized");
      try {
        final token = await _tokenStorage.getToken();
        if (token == null) {
          print("Trying to get existing token but not token found");
          onAuthetnicationFailed?.call();
          handler.next(err);
          return;
        }

        print("Refreshing with refresh_token");

        // refresh ouath with token
        final refreshedToken = await _authClient.refreshToken(
          AuthToken(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
          ),
        );

        print("refresh_token updated");

        // Update token
        await _tokenStorage.setToken(
          AuthToken(
            accessToken: refreshedToken.accessToken,
            refreshToken: refreshedToken.refreshToken,
          ),
        );

        final response = err.response;
        if (response == null) {
          handler.next(err);
          return;
        }

        final retriedResponse = await dio.request(
          response.requestOptions.path,
          cancelToken: response.requestOptions.cancelToken,
          data: response.requestOptions.data,
          onReceiveProgress: response.requestOptions.onReceiveProgress,
          onSendProgress: response.requestOptions.onSendProgress,
          queryParameters: response.requestOptions.queryParameters,
          options: Options(
            method: response.requestOptions.method,
            sendTimeout: response.requestOptions.sendTimeout,
            receiveTimeout: response.requestOptions.receiveTimeout,
            extra: response.requestOptions.extra,
            headers: response.requestOptions.headers
              ..addAll({
                "Authorization": "Bearer $refreshedToken",
              }),
            responseType: response.requestOptions.responseType,
            contentType: response.requestOptions.contentType,
            validateStatus: response.requestOptions.validateStatus,
            receiveDataWhenStatusError:
                response.requestOptions.receiveDataWhenStatusError,
            followRedirects: response.requestOptions.followRedirects,
            maxRedirects: response.requestOptions.maxRedirects,
            requestEncoder: response.requestOptions.requestEncoder,
            responseDecoder: response.requestOptions.responseDecoder,
            listFormat: response.requestOptions.listFormat,
          ),
        );
        handler.resolve(retriedResponse);
      } catch (e) {
        print("refresh_token update failed: $e");
        handler.reject(err);
        onAuthetnicationFailed?.call();
      }
    } else {
      handler.next(err);
    }
  }
}
