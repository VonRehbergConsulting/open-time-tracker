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
}
