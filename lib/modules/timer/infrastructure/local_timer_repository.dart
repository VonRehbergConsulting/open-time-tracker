import 'package:open_project_time_tracker/app/storage/timer_storage.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:rxdart/rxdart.dart';

class LocalTimerRepository implements TimerRepository {
  TimerStorage _timerStorage;

  final _state = BehaviorSubject<bool>();

  LocalTimerRepository(
    this._timerStorage,
  );

  @override
  Stream<bool> observeIsSet() => _state.doOnListen(
        () async {
          await _init();
        },
      );

  Future<void> _init() async {
    _state.add(await isSet);
  }

  Future<bool> get isSet async {
    final timeEntry = await _timerStorage.getTimeEntry();
    return timeEntry != null;
  }

  Future<bool> get hasStarted async {
    final startTime = await _timerStorage.getStartTime();
    return startTime != null;
  }

  Future<bool> get isActive async {
    final startTime = await _timerStorage.getStartTime();
    final stopTime = await _timerStorage.getStopTime();
    return startTime != null && stopTime == null;
  }

  Future<TimeEntry?> get timeEntry async {
    return _timerStorage.getTimeEntry();
  }

  Future<Duration> get timeSpent async {
    final startTime = await _timerStorage.getStartTime();
    if (startTime == null) {
      return const Duration();
    }
    final stopTime = await _timerStorage.getStopTime();
    var greaterTime = stopTime ?? DateTime.now();
    return greaterTime.difference(startTime);
  }

  Future<void> setTimeEntry({
    required TimeEntry timeEntry,
  }) async {
    DateTime? startTime;
    DateTime? stopTime;
    if (timeEntry.hours.inSeconds > 0) {
      stopTime = DateTime.now();
      startTime = stopTime.add(-timeEntry.hours);
    }
    await Future.wait([
      _timerStorage.setTimeEntry(timeEntry),
      _timerStorage.setStartTime(startTime),
      _timerStorage.setStopTime(stopTime),
    ]);
    _state.add(true);
  }

  Future<void> startTimer({
    required DateTime startTime,
  }) async {
    DateTime? startTime = await _timerStorage.getStartTime();
    DateTime? stopTime = await _timerStorage.getStopTime();

    if (startTime == null) {
      stopTime = null;
      startTime = DateTime.now();
    } else if (stopTime != null) {
      final duration = DateTime.now().difference(stopTime);
      startTime = startTime.add(duration);
      stopTime = null;
    }
    await Future.wait([
      _timerStorage.setStartTime(startTime),
      _timerStorage.setStopTime(stopTime)
    ]);
  }

  Future<void> stopTimer({
    required DateTime stopTime,
  }) async {
    final startTime = await _timerStorage.getStartTime();
    DateTime? stopTime = await _timerStorage.getStopTime();
    final timeEntry = await _timerStorage.getTimeEntry();
    if (stopTime == null) {
      stopTime = DateTime.now();
      await _timerStorage.setStopTime(stopTime);
    }
    if (startTime != null) {
      timeEntry?.hours = stopTime.difference(startTime);
      await _timerStorage.setTimeEntry(timeEntry);
    }
  }

  Future<void> reset() async {
    await Future.wait([
      _timerStorage.setTimeEntry(null),
      _timerStorage.setStartTime(null),
      _timerStorage.setStopTime(null),
    ]);
    _state.add(false);
  }

  @override
  Future<void> add(Duration duration) async {
    var startTime = await _timerStorage.getStartTime();
    if (startTime == null) {
      final date = DateTime.now();
      _timerStorage.setStopTime(date);
      startTime = date;
    }
    final newStartTime = startTime.add(-duration);
    await _timerStorage.setStartTime(newStartTime);
  }
}
