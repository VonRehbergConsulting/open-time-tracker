import 'package:json_annotation/json_annotation.dart';

part 'graph_api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class GraphApiResponse<T> {
  @JsonKey(name: 'value')
  final T value;

  GraphApiResponse({
    required this.value,
  });

  factory GraphApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$GraphApiResponseFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$GraphApiResponseToJson(this, toJsonT);
}

@JsonSerializable(genericArgumentFactories: true)
class GraphApiListResponse<T> {
  @JsonKey(name: 'value')
  final List<T> value;

  GraphApiListResponse({
    required this.value,
  });

  factory GraphApiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$GraphApiListResponseFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$GraphApiListResponseToJson(this, toJsonT);
}
