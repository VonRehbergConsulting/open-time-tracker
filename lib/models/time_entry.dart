import '/models/work_package.dart';

class TimeEntry {
  int? id;
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

  TimeEntry.forWorkPackage(WorkPackage workPackage)
      : workPackageSubject = workPackage.subject,
        projectTitle = workPackage.projectTitle,
        hours = const Duration();
}
