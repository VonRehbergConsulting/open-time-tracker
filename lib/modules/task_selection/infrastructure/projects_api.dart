import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

part 'projects_api.g.dart';

@RestApi()
abstract class ProjectsApi {
  factory ProjectsApi(Dio dio) = _ProjectsApi;

  @GET('/projects')
  Future<ProjectListResponse> projects({
    @Query('filters') String? filters,
    @Query('pageSize') int? pageSize,
    @Query('sortBy') String? sortBy,
  });
}

class ProjectResponse {
  late String id;
  late String title;
  late DateTime? updatedAt;

  ProjectResponse.fromJson(Map<String, dynamic> json) {
    id = json['identifier'];
    title = json['name'];
    updatedAt = DateTime.tryParse(json['updatedAt']);
  }
}

class ProjectListResponse {
  late List<ProjectResponse> projects;

  ProjectListResponse.fromJson(Map<String, dynamic> json) {
    List<ProjectResponse> items = [];
    final embedded = json['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    for (final element in elements) {
      items.add(ProjectResponse.fromJson(element));
    }
    projects = items;
  }
}
