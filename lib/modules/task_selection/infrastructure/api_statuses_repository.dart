import 'package:open_project_time_tracker/modules/task_selection/domain/statuses_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/statuses_api.dart';

class ApiStatusesRepository implements StatusesRepository {
  final StatusesApi restApi;

  const ApiStatusesRepository(this.restApi);

  @override
  Future<List<Status>> list() async {
    final response = await restApi.statuses();
    return response.statuses
        .map(
          (e) => Status(
            id: e.id,
            name: e.name,
          ),
        )
        .toList();
  }
}
