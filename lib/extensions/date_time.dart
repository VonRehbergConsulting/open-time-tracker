extension Weekdays on DateTime {
  DateTime get thisMonday {
    return DateTime(year, month, day - (weekday - 1));
  }

  DateTime get thisTuesday {
    return thisMonday.add(const Duration(days: 1));
  }

  DateTime get thisWednesday {
    return thisMonday.add(const Duration(days: 2));
  }

  DateTime get thisThursday {
    return thisMonday.add(const Duration(days: 3));
  }

  DateTime get thisFriday {
    return thisMonday.add(const Duration(days: 4));
  }

  DateTime get thisSaturday {
    return thisMonday.add(const Duration(days: 5));
  }

  DateTime get thisSunday {
    return thisMonday.add(const Duration(days: 6));
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Returns the date part only (year/month/day at 00:00 local time).
  DateTime get dateOnly => DateTime(year, month, day);

  /// True when this date (ignoring time-of-day) matches today's local date.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
