class TimeEntry {
  int id;
  String workPackageSubject;
  String projectTitle;
  Duration hours;
  String? comment;

  TimeEntry({
    required this.id,
    required this.workPackageSubject,
    required this.projectTitle,
    required this.hours,
    this.comment,
  });
}
