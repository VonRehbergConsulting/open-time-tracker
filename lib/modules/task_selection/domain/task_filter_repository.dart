/// Persisted task-selection UI filter state.
///
/// Kept in the task-selection module because these values only make
/// sense in the context of the work-packages list / filter screens.
/// Cross-cutting user preferences (working hours, analytics consent)
/// live in [UserPreferencesRepository] under `lib/app/preferences/`.
abstract class TaskFilterRepository {
  Future<Set<int>> get workPackagesStatusFilter;
  Future<void> setWorkPackagesStatusFilter(Set<int> value);

  /// 0 = only tasks assigned to the current user; 1 = all tasks.
  Future<int> get assigneeFilter;
  Future<void> setAssigneeFilter(int value);
}
