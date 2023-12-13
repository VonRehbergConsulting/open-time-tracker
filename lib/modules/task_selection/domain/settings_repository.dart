abstract class SettingsRepository {
  Future<Duration> get workingHours;

  Future<void> setWorkingHours(Duration value);

  Future<Set<int>> get workPackagesStatusFilter;

  Future<void> setWorkPackagesStatusFilter(Set<int> value);
}
