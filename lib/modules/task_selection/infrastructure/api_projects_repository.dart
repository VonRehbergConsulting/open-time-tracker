import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/projects_api.dart';

class ApiProjectsRepository implements ProjectsRepository {
  final ProjectsApi restApi;

  const ApiProjectsRepository(this.restApi);

  @override
  Future<List<Project>> list({
    String? userId,
    bool? active,
    int? pageSize,
  }) async {
    List<String> filters = [];
    if (userId != null) {
      filters.add('{"visible":{"operator":"=","values":["$userId"]}}');
    }
    if (active != null) {
      filters.add(
          '{"active":{"operator":"=","values":["${active ? 't' : 'f'}"]}}');
    }
    final filtersString = '[${filters.join(', ')}]';

    final response = await restApi.projects(
      filters: filtersString,
      pageSize: pageSize,
    );
    return response.projects
        .map((element) => Project(
              id: element.id,
              title: element.title,
              createdAt: element.createdAt,
            ))
        .toList();
  }
}
