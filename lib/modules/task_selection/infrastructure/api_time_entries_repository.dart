import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/time_entries_api.dart';

/// Maximum number of pages to fetch when fetchAll is true (safety limit to prevent infinite loops)
const int _kMaxPaginationPages = 100;

class ApiTimeEntriesRepository implements TimeEntriesRepository {
  final TimeEntriesApi _restApi;

  ApiTimeEntriesRepository(this._restApi);

  @override
  Future<List<TimeEntry>> list({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? workPackageId,
    int? pageSize,
    bool fetchAll = false,
  }) async {
    List<String> filters = [];
    if (userId != null) {
      filters.add('{"user":{"operator":"=","values":["$userId"]}}');
    }
    if (startDate != null && endDate != null) {
      filters.add(
        '{"spent_on":{"operator":"<>d","values":["$startDate", "$endDate"]}}',
      );
    }
    // keep work package filter last to replace it further for compartability with old API versions
    if (workPackageId != null) {
      filters.add('{"entity":{"operator":"=","values":["$workPackageId"]}}');
    }
    final filtersString = '[${filters.join(', ')}]';

    // Fetch all pages if fetchAll is true, otherwise just fetch first page
    final List<TimeEntryResponse> allEntries = [];
    int offset = 1;
    int? total;
    int maxPages = _kMaxPaginationPages;
    
    do {
      TimeEntriesResponse result;
      try {
        result = await _restApi.timeEntries(
          filters: filtersString,
          pageSize: pageSize,
          offset: offset,
        );
      } on DioException catch (e) {
        // retry with deprecated old filter for older instances
        if (e.response?.statusCode == 400 && workPackageId != null) {
          filters.removeLast();
          filters.add(
            '{"workPackage":{"operator":"=","values":["$workPackageId"]}}',
          );
          final updatedFiltersString = '[${filters.join(', ')}]';
          result = await _restApi.timeEntries(
            filters: updatedFiltersString,
            pageSize: pageSize,
            offset: offset,
          );
        } else {
          rethrow;
        }
      }

      allEntries.addAll(result.timeEntries);
      total = result.total;
      
      // Break if no more entries returned
      if (result.timeEntries.isEmpty || result.count == 0) {
        break;
      }
      
      // Only continue fetching if fetchAll is true
      if (!fetchAll) {
        break;
      }
      
      offset++; // Move to next page (offset is page number, not item number)
      maxPages--;
      
      // Continue fetching if there are more results
    } while (allEntries.length < total && maxPages > 0);

    allEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final List<TimeEntry> items = allEntries
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
  Future<TimeEntry> create({
    required TimeEntry timeEntry,
    required int userId,
  }) async {
    final body = {
      'user': {'id': userId},
      'workPackage': {'href': timeEntry.workPackageHref},
      'project': {'href': timeEntry.projectHref},
      'spentOn': DateFormat('yyyy-MM-dd').format(timeEntry.spentOn),
      'hours': timeEntry.hours.toISO8601(),
      'comment': {'format': 'plain', 'raw': timeEntry.comment},
    };
    final response = await _restApi.createTimeEntry(body: body);
    // Parse the response to get the ID and update the timeEntry
    final data = response.data;
    timeEntry.id = data['id'];
    return timeEntry;
  }

  @override
  Future<TimeEntry> update({required TimeEntry timeEntry}) async {
    if (timeEntry.id == null) {
      throw Exception('Updating time entry without id');
    }
    final body = {
      'hours': timeEntry.hours.toISO8601(),
      'comment': {'format': 'plain', 'raw': timeEntry.comment},
    };
    await _restApi.updateTimeEntry(id: timeEntry.id, body: body);
    return timeEntry;
  }

  @override
  Future<void> delete({required int id}) async {
    await _restApi.deleteTimeEntry(id: id);
  }
}
