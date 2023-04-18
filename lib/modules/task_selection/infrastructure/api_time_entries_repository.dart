import 'package:intl/intl.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/time_entries_api.dart';

class ApiTimeEntriesRepository implements TimeEntriesRepository {
  TimeEntriesApi _restApi;

  ApiTimeEntriesRepository(this._restApi);

  @override
  Future<List<TimeEntry>> list({
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? workPackageId,
  }) async {
    List<String> filters = [];
    if (userId != null) {
      filters.add('{"user":{"operator":"=","values":["$userId"]}}');
    }
    if (startDate != null && endDate != null) {
      filters.add(
          '{"spent_on":{"operator":"<>d","values":["$startDate", "$endDate"]}}');
    }
    if (workPackageId != null) {
      filters
          .add('{"workPackage":{"operator":"=","values":["$workPackageId"]}}');
    }
    final filtersString = '[${filters.join(', ')}]';
    final result = await _restApi.timeEntries(
      filters: filtersString,
    );
    result.timeEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final items = result.timeEntries
        .map(
          (e) => TimeEntry(
            id: e.id,
            workPackageSubject: e.workPackageSubject,
            workPackageHref: e.workPackageHref,
            projectTitle: e.projectTitle,
            projectHref: e.projectHref,
            hours: e.hours,
            spentOn: e.spentOn,
            comment: e.comment,
          ),
        )
        .toList();
    return items;
  }

  @override
  Future<void> create(
      {required TimeEntry timeEntry, required int userId}) async {
    final body = {
      'user': {'id': userId},
      'workPackage': {'href': timeEntry.workPackageHref},
      'project': {'href': timeEntry.projectHref},
      'spentOn': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'hours': timeEntry.hours.toISO8601(),
      'comment': {
        'format': 'plain',
        'raw': timeEntry.comment,
      }
    };
    await _restApi.createTimeEntry(body: body);
  }

  @override
  Future<void> update({required TimeEntry timeEntry}) async {
    if (timeEntry.id == null) {
      throw Exception('Updating time entry without id');
    }
    final body = {
      'hours': timeEntry.hours.toISO8601(),
      'comment': {
        'format': 'plain',
        'raw': timeEntry.comment,
      },
    };
    await _restApi.updateTimeEntry(
      id: timeEntry.id,
      body: body,
    );
  }

  @override
  Future<void> delete({required int id}) async {
    await _restApi.deleteTimeEntry(id: id);
  }
}
