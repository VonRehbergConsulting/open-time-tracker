import 'dart:convert';

import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/task_filter_repository.dart';

/// [SharedPreferences]-backed implementation of [TaskFilterRepository].
///
/// Storage keys are preserved verbatim from the previous
/// `LocalSettingsRepository` so users keep their configured filters
/// across the split.
class LocalTaskFilterRepository implements TaskFilterRepository {
  LocalTaskFilterRepository(this._storage);

  final PreferencesStorage _storage;

  static const _workPackagesStatusFilterKey = 'workPackagesStatusFilter';
  static const _assigneeFilterKey = 'assigneeFilter';

  @override
  Future<Set<int>> get workPackagesStatusFilter async {
    try {
      final string = await _storage.getString(_workPackagesStatusFilterKey);
      return Set.from(json.decode(string!)).cast<int>();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> setWorkPackagesStatusFilter(Set<int> value) async {
    await _storage.setString(
      _workPackagesStatusFilterKey,
      value.toList().toString(),
    );
  }

  @override
  Future<int> get assigneeFilter async {
    const defaultValue = 0;
    try {
      return await _storage.getInt(_assigneeFilterKey) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  @override
  Future<void> setAssigneeFilter(int value) async {
    await _storage.setInt(_assigneeFilterKey, value);
  }
}
