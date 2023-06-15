import '../../task_selection/domain/time_entries_repository.dart';

abstract class TimerService {
  Future<void> submit({TimeEntry? timeEntry});
}
