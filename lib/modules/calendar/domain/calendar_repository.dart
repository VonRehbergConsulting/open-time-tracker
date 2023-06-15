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
  final String subject;

  CalendarEntry({
    required this.isRecurring,
    required this.isReminderSet,
    required this.start,
    required this.end,
    required this.subject,
  });
}
