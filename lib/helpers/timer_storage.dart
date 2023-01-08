import 'dart:convert';

import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

import '/helpers/preferences_storage.dart';
import '/helpers/time_entry_serialization.dart';

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
      return TimeEntrySerialization.parse(decoded);
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
    final string = jsonEncode(
      TimeEntrySerialization.toMap(timeEntry),
    );
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
