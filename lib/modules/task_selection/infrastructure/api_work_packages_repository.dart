import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/work_packages_api.dart';

class ApiWorkPackagesRepository implements WorkPackagesRepository {
  WorkPackagesApi restApi;

  ApiWorkPackagesRepository(this.restApi);

  @override
  Future<List<WorkPackage>> list({
    String? projectId,
    int? pageSize,
    Set<int>? statuses,
  }) async {
    List<String> filters = [];
    filters.add('{"assigneeOrGroup":{"operator":"=","values":["me"]}}');
    if (statuses != null && statuses.isNotEmpty) {
      final statusesString = statuses.map((e) => '"$e"').join(', ');
      filters.add('{"status":{"operator":"=","values":[$statusesString]}}');
    } else {
      filters.add('{"status":{"operator":"o","values":[]}}');
    }
    final filtersString = '[${filters.join(', ')}]';

    WorkPackagesListResponse response;
    if (projectId != null) {
      response = await restApi.workPackagesOfProject(
        projectId: projectId,
        filters: filtersString,
        pageSize: pageSize,
      );
    } else {
      response = await restApi.workPackages(
        filters: filtersString,
        pageSize: pageSize,
      );
    }

    return response.workPackages
        .map(
          (e) => WorkPackage(
              id: e.id,
              subject: e.subject,
              href: e.href,
              projectTitle: e.projectTitle,
              projectHref: e.projectHref,
              priority: e.priority,
              status: e.status,
              assignee: WorkPackageAssignee(
                type: switch (e.assignee.type) {
                  WorkPackageAssigneeTypeResponse.user =>
                    WorkPackageAssigneeType.user,
                  WorkPackageAssigneeTypeResponse.group =>
                    WorkPackageAssigneeType.group,
                },
                title: e.assignee.title,
              )),
        )
        .toList();
  }
}
