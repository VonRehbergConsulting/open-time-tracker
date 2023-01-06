abstract class SettingsRepository {
  Future<Duration> get workingHours;

  Future<void> setWorkingHours(Duration value);
}
