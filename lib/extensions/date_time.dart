extension Weekdays on DateTime {
  DateTime get thisMonday {
    return DateTime(this.year, this.month, this.day - (this.weekday - 1));
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
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
