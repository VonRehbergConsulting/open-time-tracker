import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

abstract class TimerRepository {
  Future<bool> get isSet;
  Future<bool> get hasStarted;
  Future<bool> get isActive;

  Future<TimeEntry?> get timeEntry;
  Future<Duration> get timeSpent;

  Stream<bool> observeIsSet();

  Future<void> setTimeEntry({
    required TimeEntry timeEntry,
  });

  Future<void> startTimer({
    required DateTime startTime,
  });

  Future<void> stopTimer({
    required DateTime stopTime,
  });

  Future<void> reset();
}
