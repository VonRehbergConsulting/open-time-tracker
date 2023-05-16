import 'package:iso_duration_parser/iso_duration_parser.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';

abstract class TimeEntriesRepository {
  Future<List<TimeEntry>> list({
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? workPackageId,
    int? pageSize,
  });

  Future<void> create({
    required TimeEntry timeEntry,
    required int userId,
  });

  Future<void> update({
    required TimeEntry timeEntry,
  });

  Future<void> delete({
    required int id,
  });
}

class TimeEntry {
  late int? id;
  late String workPackageSubject;
  late String workPackageHref;
  late String projectTitle;
  late String projectHref;
  late Duration hours;
  late DateTime spentOn;
  late String? comment;

  TimeEntry({
    required this.id,
    required this.workPackageSubject,
    required this.workPackageHref,
    required this.projectTitle,
    required this.projectHref,
    required this.hours,
    required this.spentOn,
    required this.comment,
  });

  TimeEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    final commentJson = json["comment"];
    comment = commentJson["raw"];

    final links = json["_links"];
    final project = links["project"];
    projectTitle = project["title"];
    projectHref = project["href"];
    final workPackage = links["workPackage"];
    workPackageSubject = workPackage["title"];
    workPackageHref = workPackage["href"];
    spentOn = DateTime.parse(json['spentOn']);

    final hoursString = json["hours"];
    hours =
        Duration(seconds: IsoDuration.parse(hoursString).toSeconds().round());
    if (hours.inSeconds.remainder(60) == 59) {
      hours += const Duration(seconds: 1);
    }
  }

  TimeEntry.fromWorkPackage(WorkPackage workPackage)
      : id = null,
        workPackageSubject = workPackage.subject,
        workPackageHref = workPackage.href,
        projectTitle = workPackage.projectTitle,
        projectHref = workPackage.projectHref,
        hours = const Duration(),
        spentOn = DateTime.now(),
        comment = null;
}
