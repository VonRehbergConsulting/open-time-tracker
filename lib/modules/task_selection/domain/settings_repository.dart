abstract class SettingsRepository {
  Future<Duration> get workingHours;
  Future<void> setWorkingHours(Duration value);

  Future<Set<int>> get workPackagesStatusFilter;
  Future<void> setWorkPackagesStatusFilter(Set<int> value);

  // 0 - only my tasks
  // 1 - all tasks
  Future<int> get assigneeFilter;
  Future<void> setAssigneeFilter(int value);

  Future<bool?> get analyticsConsent;
  Future<void> setAnalyticsConsent(bool value);

  /// Filter projects to only those that have tasks.
  ///
  /// This is used in the project selection list.
  Future<bool> get showOnlyProjectsWithTasks;
  Future<void> setShowOnlyProjectsWithTasks(bool value);

  /// Do not load the project list automatically.
  ///
  /// When enabled, the project selection list will require a manual refresh/
  /// load trigger by the user.
  Future<bool> get doNotLoadProjectList;
  Future<void> setDoNotLoadProjectList(bool value);
}
