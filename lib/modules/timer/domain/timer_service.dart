import '../../task_selection/domain/time_entries_repository.dart';

abstract class TimerService {
  Future<TimeEntry> submit({TimeEntry? timeEntry});
}
