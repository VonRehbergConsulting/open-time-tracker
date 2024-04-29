import 'package:open_project_time_tracker/modules/task_selection/domain/groups_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/groups_api.dart';

class ApiGroupsRepository implements GroupsRepository {
  final GroupsApi restApi;

  const ApiGroupsRepository(this.restApi);

  @override
  Future<List<Group>> list({
    int? pageSize,
  }) async {
    final response = await restApi.groups(
      pageSize: pageSize,
    );
    return response.groups
        .map(
          (e) => Group(
            id: e.id,
            name: e.name,
            memberIds: e.memberIds,
          ),
        )
        .toList();
  }
}
