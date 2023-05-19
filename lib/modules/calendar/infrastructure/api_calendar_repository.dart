import 'package:open_project_time_tracker/modules/calendar/domain/calendar_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/graph_calendar_api.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/graph_user_api.dart';

class ApiCalendarRepository implements CalendarRepository {
  GraphCalendarApi _calendarApi;
  GraphUserApi _graphUserApi;

  ApiCalendarRepository(
    this._calendarApi,
    this._graphUserApi,
  );

  @override
  Future<List<CalendarEntry>> list({
    required DateTime start,
    required DateTime end,
  }) async {
    // TODO: cache username and timezone
    final userResponse = await _graphUserApi.me();
    final timeZoneResponse = await _graphUserApi.timeZone();

    final body = GetScheduleRequestBody(
      names: [userResponse.value],
      timeZone: timeZoneResponse.value,
      startTime: start,
      endTime: end,
    );
    final schedule = await _calendarApi.getSchedule(
      body: body,
    );

    final startParsed =
        DateTime.parse(schedule.value[0].items[0].start.dateTime + 'Z')
            .toLocal();
    final endParsed =
        DateTime.parse(schedule.value[0].items[0].end.dateTime + 'Z').toLocal();

    return schedule.value[0].items
        .map((e) => CalendarEntry(
              isRecurring: e.isRecurring,
              isReminderSet: e.isReminderSet,
              start: startParsed,
              end: endParsed,
            ))
        .toList();
  }
}
