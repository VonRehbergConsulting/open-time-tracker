import 'package:json_annotation/json_annotation.dart';

part 'rest_api_response.g.dart';

@JsonSerializable()
class VoidRestApiResponse {
  @JsonKey(name: 'status')
  final int status;

  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'message')
  final String? message;

  VoidRestApiResponse({
    required this.status,
    required this.success,
    required this.message,
  });

  factory VoidRestApiResponse.fromJson(Map<String, dynamic> json) =>
      _$VoidRestApiResponseFromJson(json);
}

@JsonSerializable(genericArgumentFactories: true)
class RestApiResponse<T> {
  @JsonKey(name: 'status')
  final int status;

  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'data')
  final T data;

  RestApiResponse({
    required this.status,
    required this.success,
    required this.data,
  });

  factory RestApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$RestApiResponseFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$RestApiResponseToJson(this, toJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class RestApiListResponse<T> {
  @JsonKey(name: 'status')
  final int status;

  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'data')
  final List<T> data;

  RestApiListResponse({
    required this.status,
    required this.success,
    required this.data,
  });

  factory RestApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$RestApiListResponseFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$RestApiListResponseToJson(this, toJsonT);
}
