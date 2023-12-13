import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';

part 'statuses_api.g.dart';

@RestApi()
abstract class StatusesApi {
  factory StatusesApi(Dio dio) = _StatusesApi;

  @GET('/statuses')
  Future<StatusListResponse> statuses();
}

class StatusResponse {
  late int id;
  late String name;

  StatusResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class StatusListResponse {
  late List<StatusResponse> statuses;

  StatusListResponse.fromJson(Map<String, dynamic> json) {
    List<StatusResponse> items = [];
    final embedded = json['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    for (final element in elements) {
      items.add(StatusResponse.fromJson(element));
    }
    statuses = items;
  }
}
