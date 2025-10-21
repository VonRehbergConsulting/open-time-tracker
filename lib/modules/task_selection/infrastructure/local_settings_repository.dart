import 'dart:convert';

import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  final PreferencesStorage _storage;

  LocalSettingsRepository(this._storage);

  final String _workingHoursKey = 'workingHours';
  final String _workPackagesStatusFilterKey = 'workPackagesStatusFilter';
  final String _assigneeFilterKey = 'assigneeFilter';
  final String _analyticsConsent = 'analyticsConsent';

  // working hours

  static Duration get _defaultWorkingHours {
    return const Duration(hours: 8);
  }

  @override
  Future<Duration> get workingHours async {
    final string = await _storage.getString(_workingHoursKey);
    if (string == null) {
      return _defaultWorkingHours;
    }
    final minutes = int.tryParse(string);
    if (minutes == null) {
      return _defaultWorkingHours;
    }
    return Duration(minutes: minutes);
  }

  @override
  Future<void> setWorkingHours(Duration value) async {
    final valueString = value.inMinutes.toString();
    await _storage.setString(_workingHoursKey, valueString);
  }

  // work packages filter

  @override
  Future<Set<int>> get workPackagesStatusFilter async {
    try {
      final string = await _storage.getString(_workPackagesStatusFilterKey);
      final set = Set.from(json.decode(string!)).cast<int>();
      return set;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> setWorkPackagesStatusFilter(Set<int> value) async {
    final string = value.toList().toString();
    await _storage.setString(_workPackagesStatusFilterKey, string);
  }

  @override
  Future<int> get assigneeFilter async {
    const defaultValue = 0;
    try {
      return await _storage.getInt(_assigneeFilterKey) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  Future<void> setAssigneeFilter(int value) async {
    await _storage.setInt(_assigneeFilterKey, value);
  }

  @override
  Future<bool?> get analyticsConsent async {
    return await _storage.getBool(_analyticsConsent);
  }

  @override
  Future<void> setAnalyticsConsent(bool value) async {
    await _storage.setBool(_analyticsConsent, value);
  }
}
