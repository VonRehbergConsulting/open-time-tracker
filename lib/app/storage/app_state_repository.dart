abstract class AppStateRepository {
  /// Get the currently selected date for viewing time entries
  Future<DateTime?> get selectedDate;

  /// Set the selected date for viewing time entries
  Future<void> setSelectedDate(DateTime date);

  /// Clear the selected date (resets to today)
  Future<void> clearSelectedDate();
}
