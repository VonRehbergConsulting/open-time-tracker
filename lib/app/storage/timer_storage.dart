import 'dart:convert';

import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

import 'preferences_storage.dart';

class TimerStorage {
  // Properties

  PreferencesStorage storage;

  final String _timeEntryKey = 'timeEntry';
  final String _startTimeKey = 'statTime';
  final String _stopTimeKey = 'stopTime';

  // Init

  TimerStorage(this.storage);

  //Private methods

  Future<void> _saveDateTime(String key, DateTime? dateTime) async {
    if (dateTime == null) {
      storage.remove(key);
      return;
    }
    final value = dateTime.toIso8601String();
    await storage.setString(key, value);
  }

  Future<DateTime?> _loadDateTime(String key) async {
    final string = await storage.getString(key);
    if (string == null) {
      return null;
    }
    return DateTime.tryParse(string);
  }

  // Public methods

  Future<TimeEntry?> getTimeEntry() async {
    final string = await storage.getString(_timeEntryKey);
    try {
      final decoded = jsonDecode(string!);
      print('Time entry loaded');
      return _TimeEntrySerialization.parse(decoded);
    } catch (error) {
      print('Can\'t load time entry');
      return null;
    }
  }

  Future<void> setTimeEntry(TimeEntry? timeEntry) async {
    if (timeEntry == null) {
      storage.remove(_timeEntryKey);
      return;
    }
    final string = jsonEncode(_TimeEntrySerialization.toMap(timeEntry));
    await storage.setString(_timeEntryKey, string);
    print('Time entry saved');
  }

  Future<DateTime?> getStartTime() async {
    return _loadDateTime(_startTimeKey);
  }

  Future<void> setStartTime(DateTime? dateTime) async {
    return _saveDateTime(_startTimeKey, dateTime);
  }

  Future<DateTime?> getStopTime() async {
    return _loadDateTime(_stopTimeKey);
  }

  Future<void> setStopTime(DateTime? dateTime) async {
    return _saveDateTime(_stopTimeKey, dateTime);
  }
}

class _TimeEntrySerialization {
  static Map<String, dynamic> toMap(TimeEntry timeEntry) {
    return {
      'id': timeEntry.id,
      'workPackageSubject': timeEntry.workPackageSubject,
      'workPackageHref': timeEntry.workPackageHref,
      'projectTitle': timeEntry.projectTitle,
      'projectHref': timeEntry.projectHref,
      'hours': timeEntry.hours.inSeconds,
      'spentOn': timeEntry.spentOn.toString(),
      'comment': timeEntry.comment,
    };
  }

  static TimeEntry? parse(Map<String, dynamic> object) {
    try {
      final id = object['id'] as int?;
      final String workPackageSubject = object['workPackageSubject'];
      final String workPackageHref = object['workPackageHref'];
      final String projectTitle = object['projectTitle'];
      final String projectHref = object['projectHref'];
      final Duration hours = Duration(seconds: object['hours'] as int);
      final DateTime spentOn = DateTime.parse(object['spentOn']);
      final String? comment = object['comment'];
      return TimeEntry(
        id: id,
        workPackageSubject: workPackageSubject,
        workPackageHref: workPackageHref,
        projectTitle: projectTitle,
        projectHref: projectHref,
        hours: hours,
        spentOn: spentOn,
        comment: comment,
      );
    } catch (error) {
      print('Can\'t parse time entry');
      return null;
    }
  }
}
