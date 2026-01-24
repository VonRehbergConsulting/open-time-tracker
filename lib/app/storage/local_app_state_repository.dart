import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
import 'package:open_project_time_tracker/app/storage/app_state_storage.dart';

class LocalAppStateRepository implements AppStateRepository {
  final AppStateStorage _appStateStorage;

  LocalAppStateRepository(this._appStateStorage);

  @override
  Future<DateTime?> get selectedDate async {
    final dateString = await _appStateStorage.selectedDate;
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  @override
  Future<void> setSelectedDate(DateTime date) async {
    await _appStateStorage.setSelectedDate(date.toIso8601String());
  }

  @override
  Future<void> clearSelectedDate() async {
    await _appStateStorage.clearSelectedDate();
  }
}
