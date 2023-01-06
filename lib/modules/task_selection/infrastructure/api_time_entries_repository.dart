import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/time_entries_api.dart';

class ApiTimeEntriesRepository implements TimeEntriesRepository {
  TimeEntriesApi restApi;

  ApiTimeEntriesRepository(this.restApi);

  @override
  Future<List<TimeEntry>> list({
    int? userId,
    DateTime? date,
  }) async {
    List<String> filters = [];
    if (userId != null) {
      filters.add('{"user":{"operator":"=","values":["$userId"]}}');
    }
    if (date != null) {
      filters.add('{"spent_on":{"operator":"=d","values":["$date"]}}');
    }
    final filtersString = '[${filters.join(', ')}]';
    final result = await restApi.timeEntries(
      filters: filtersString,
    );
    final items = result.timeEntries
        .map(
          (e) => TimeEntry(
              id: e.id,
              workPackageSubject: e.workPackageSubject,
              workPackageHref: e.workPackageHref,
              projectTitle: e.projectTitle,
              projectHref: e.projectHref,
              hours: e.hours,
              comment: e.comment),
        )
        .toList();
    return items;
  }
}
