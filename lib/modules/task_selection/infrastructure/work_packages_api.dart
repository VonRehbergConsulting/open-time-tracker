import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'work_packages_api.g.dart';

@RestApi()
abstract class WorkPackagesApi {
  factory WorkPackagesApi(Dio dio) = _WorkPackagesApi;

  @GET('/work_packages')
  Future<WorkPackagesListResponse> workPackages({
    @Query('filters') String? filters,
    @Query('pageSize') int? pageSize,
  });
}

class WorkPackageResponse {
  late int id;
  late String subject;
  late String href;
  late String projectTitle;
  late String projectHref;
  late String priority;
  late String status;

  WorkPackageResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    subject = json["subject"];

    final links = json["_links"];
    final project = links["project"];
    projectTitle = project["title"];
    projectHref = project["href"];

    final self = links["self"];
    href = self["href"];

    final priorityJson = links["priority"];
    priority = priorityJson['title'];

    final statusJson = links["status"];
    status = statusJson['title'];
  }
}

class WorkPackagesListResponse {
  late List<WorkPackageResponse> workPackages;

  WorkPackagesListResponse.fromJson(Map<String, dynamic> json) {
    List<WorkPackageResponse> items = [];
    final embedded = json['_embedded'];
    final elements = embedded['elements'] as List<dynamic>;
    for (var element in elements) {
      items.add(WorkPackageResponse.fromJson(element));
    }
    workPackages = items;
  }
}
