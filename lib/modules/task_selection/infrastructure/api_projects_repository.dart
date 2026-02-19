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
    bool sortByName = false,
    bool assignedToUser = false,
    bool favoritesOnly = false,
  }) async {
    List<String> filters = [];
    if (userId != null) {
      filters.add('{"visible":{"operator":"=","values":["$userId"]}}');
    }
    if (active != null) {
      filters.add(
          '{"active":{"operator":"=","values":["${active ? 't' : 'f'}"]}}');
    }
    if (assignedToUser) {
      filters.add('{"member_of":{"operator":"=","values":["t"]}}');
    }
    if (favoritesOnly) {
      filters.add('{"favorited":{"operator":"=","values":["t"]}}');
    }
    final filtersString = '[${filters.join(', ')}]';

    List<String> sorters = [];
    if (sortByName) {
      sorters.add('["name", "asc"]');
    }
    final sortString = '[${sorters.join(', ')}]';

    final response = await restApi.projects(
      filters: filtersString,
      pageSize: pageSize,
      sortBy: sortString,
    );
    return response.projects
        .map((element) => Project(
              id: element.id,
              numericId: element.numericId,
              title: element.title,
              updatedAt: element.updatedAt,
            ))
        .toList();
  }
}
