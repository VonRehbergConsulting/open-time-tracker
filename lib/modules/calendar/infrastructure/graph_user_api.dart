import 'package:dio/dio.dart' hide Headers;
import 'package:open_project_time_tracker/app/api/graph_api_response.dart';
import 'package:retrofit/retrofit.dart';

part 'graph_user_api.g.dart';

@RestApi()
abstract class GraphUserApi {
  factory GraphUserApi(Dio dio) = _GraphUserApi;

  @GET('/v1.0/me/mailboxSettings/timeZone')
  Future<GraphApiResponse<String>> timeZone();

  @GET('/v1.0/me/userPrincipalName')
  Future<GraphApiResponse<String>> me();
}
