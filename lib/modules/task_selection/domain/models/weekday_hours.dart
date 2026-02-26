class WeekdayHours {
  final Duration monday;
  final Duration tuesday;
  final Duration wednesday;
  final Duration thursday;
  final Duration friday;
  final Duration saturday;
  final Duration sunday;

  bool get isEmpty {
    return monday.inMinutes == 0 &&
        tuesday.inMinutes == 0 &&
        wednesday.inMinutes == 0 &&
        thursday.inMinutes == 0 &&
        friday.inMinutes == 0 &&
        saturday.inMinutes == 0 &&
        sunday.inMinutes == 0;
  }

  WeekdayHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });
}
