import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/work_packages_api.dart';

class ApiWorkPackagesRepository implements WorkPackagesRepository {
  WorkPackagesApi restApi;

  ApiWorkPackagesRepository(this.restApi);

  @override
  Future<List<WorkPackage>> list({
    int? userId,
    int? pageSize,
    Set<int>? statuses,
  }) async {
    List<String> filters = [];
    if (userId != null) {
      filters.add('{"assignee":{"operator":"=","values":["$userId"]}}');
    }
    if (statuses != null && statuses.isNotEmpty) {
      final statusesString = statuses.map((e) => '"$e"').join(', ');
      filters.add('{"status":{"operator":"=","values":[$statusesString]}}');
    }
    final filtersString = '[${filters.join(', ')}]';
    final response = await restApi.workPackages(
      filters: filtersString,
      pageSize: pageSize,
    );
    return response.workPackages
        .map(
          (e) => WorkPackage(
              id: e.id,
              subject: e.subject,
              href: e.href,
              projectTitle: e.projectTitle,
              projectHref: e.projectHref,
              priority: e.priority,
              status: e.status),
        )
        .toList();
  }
}
