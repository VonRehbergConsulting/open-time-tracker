import '../models/time_entry.dart';

class TimeEntrySerialization {
  static Map<String, dynamic> toMap(TimeEntry timeEntry) {
    return {
      'id': timeEntry.id,
      'workPackageSubject': timeEntry.workPackageSubject,
      'workPackageHref': timeEntry.workPackageHref,
      'projectTitle': timeEntry.projectTitle,
      'projectHref': timeEntry.projectHref,
      'hours': timeEntry.hours.inSeconds,
      'comment': timeEntry.comment,
    };
  }

  static TimeEntry? parse(Map<String, dynamic> object) {
    try {
      final id = object['id'] as int;
      final String workPackageSubject = object['workPackageSubject'];
      final String workPackageHref = object['workPackageHref'];
      final String projectTitle = object['projectTitle'];
      final String projectHref = object['projectHref'];
      final Duration hours = Duration(seconds: object['hours'] as int);
      final String comment = object['comment'];
      return TimeEntry(
        id: id,
        workPackageSubject: workPackageSubject,
        workPackageHref: workPackageHref,
        projectTitle: projectTitle,
        projectHref: projectHref,
        hours: hours,
        comment: comment,
      );
    } catch (error) {
      print('Can\'t parse time entry');
      return null;
    }
  }
}
