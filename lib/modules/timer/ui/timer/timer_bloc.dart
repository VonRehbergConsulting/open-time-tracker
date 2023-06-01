import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

import '../../../calendar/domain/calendar_notifications_service.dart';

part 'timer_bloc.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState.idle({
    required Duration timeSpent,
    required String title,
    required String subtitle,
    required bool hasStarted,
    required bool isActive,
  }) = _Idle;
}

@freezed
class TimerEffect with _$TimerEffect {
  const factory TimerEffect.finish() = _Finish;
}

class TimerBloc extends EffectCubit<TimerState, TimerEffect> {
  final TimerRepository _timerRepository;
  final CalendarNotificationsService _calendarNotificationsService;

  TimerBloc(
    this._timerRepository,
    this._calendarNotificationsService,
  ) : super(
          TimerState.idle(
            timeSpent: Duration(),
            title: '',
            subtitle: '',
            hasStarted: false,
            isActive: false,
          ),
        ) {
    _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    try {
      // TODO: make request only if is authorized
      await _calendarNotificationsService.scheduleNotifications(
        // TODO: get text from localizations
        'You have a scheduled meeting',
        'Click here to open the timer',
      );
    } catch (e) {
      print('Cannot set notifications');
    }
  }

  Future<void> updateState() async {
    final data = await Future.wait([
      _timerRepository.timeEntry,
      _timerRepository.hasStarted,
      _timerRepository.isActive,
      _timerRepository.timeSpent,
    ]);
    try {
      final timeEntry = data[0] as TimeEntry;
      final hasStarted = data[1] as bool;
      final isActive = data[2] as bool;
      final timeSpent = data[3] as Duration;
      emit(
        TimerState.idle(
          timeSpent: timeSpent,
          title: timeEntry.workPackageSubject,
          subtitle: timeEntry.projectTitle,
          hasStarted: hasStarted,
          isActive: isActive,
        ),
      );
    } catch (e) {
      print('Cannot load timer data: $e');
    }
  }

  Future<void> reset() async {
    await _calendarNotificationsService.removeNotifications();
    await _timerRepository.reset();
  }

  Future<void> start() async {
    await _timerRepository.startTimer(startTime: DateTime.now());
    await updateState();
  }

  Future<void> stop() async {
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    await updateState();
  }

  Future<void> finish() async {
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    await updateState();
    emitEffect(TimerEffect.finish());
  }

  Future<void> add(Duration duration) async {
    _timerRepository.add(duration);
    emit(
      state.copyWith(
        timeSpent: state.timeSpent + duration,
        hasStarted: true,
      ),
    );
  }
}
