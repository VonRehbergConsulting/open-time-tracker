abstract class CalendarRepository {
  Future<List<CalendarEntry>> list({
    required DateTime start,
    required DateTime end,
  });
}

class CalendarEntry {
  final bool isRecurring;
  final bool isReminderSet;
  final DateTime start;
  final DateTime end;

  CalendarEntry({
    required this.isRecurring,
    required this.isReminderSet,
    required this.start,
    required this.end,
  });
}
