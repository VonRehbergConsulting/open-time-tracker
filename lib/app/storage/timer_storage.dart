import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

import 'preferences_storage.dart';

class TimerStorage {
  // Properties

  PreferencesStorage storage;

  final String _timeEntryKey = 'timeEntry';
  final String _startTimeKey = 'startTime';
  // Legacy key from earlier versions (typo). Read once for migration, then
  // removed so subsequent runs use [_startTimeKey].
  final String _legacyStartTimeKey = 'statTime';
  final String _stopTimeKey = 'stopTime';

  // Init

  TimerStorage(this.storage);

  //Private methods

  Future<void> _saveDateTime(String key, DateTime? dateTime) async {
    if (dateTime == null) {
      await storage.remove(key);
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
    if (string == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(string);
      return _TimeEntrySerialization.parse(decoded);
    } catch (error) {
      debugPrint('TimerStorage: cannot load time entry: $error');
      return null;
    }
  }

  Future<void> setTimeEntry(TimeEntry? timeEntry) async {
    if (timeEntry == null) {
      await storage.remove(_timeEntryKey);
      return;
    }
    final string = jsonEncode(_TimeEntrySerialization.toMap(timeEntry));
    await storage.setString(_timeEntryKey, string);
  }

  Future<DateTime?> getStartTime() async {
    final current = await _loadDateTime(_startTimeKey);
    if (current != null) {
      return current;
    }
    // Migrate value written by an earlier version under a mistyped key.
    final legacy = await _loadDateTime(_legacyStartTimeKey);
    if (legacy != null) {
      await _saveDateTime(_startTimeKey, legacy);
      await storage.remove(_legacyStartTimeKey);
    }
    return legacy;
  }

  Future<void> setStartTime(DateTime? dateTime) async {
    // Always clear the legacy key to prevent stale reads after a migration.
    // Awaited so the delete is sequenced before the new value is written
    // (and before this future resolves) — see PreferencesStorage.remove.
    await storage.remove(_legacyStartTimeKey);
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
