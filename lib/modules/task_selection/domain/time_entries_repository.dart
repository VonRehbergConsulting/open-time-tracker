import 'package:iso_duration_parser/iso_duration_parser.dart';

abstract class TimeEntriesRepository {
  Future<List<TimeEntry>> list({
    int? userId,
    DateTime? date,
  });
}

class TimeEntry {
  late int? id;
  late String workPackageSubject;
  late String workPackageHref;
  late String projectTitle;
  late String projectHref;
  late Duration hours;
  late String? comment;

  TimeEntry({
    required this.id,
    required this.workPackageSubject,
    required this.workPackageHref,
    required this.projectTitle,
    required this.projectHref,
    required this.hours,
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

    final hoursString = json["hours"];
    hours =
        Duration(seconds: IsoDuration.parse(hoursString).toSeconds().round());
    if (hours.inSeconds.remainder(60) == 59) {
      hours += const Duration(seconds: 1);
    }
  }
}
