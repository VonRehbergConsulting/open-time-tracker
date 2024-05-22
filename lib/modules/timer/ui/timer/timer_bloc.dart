import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

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
  final LiveActivityManager _liveActivityManager;

  TimerBloc(
    this._timerRepository,
    this._liveActivityManager,
  ) : super(
          const TimerState.idle(
            timeSpent: Duration(),
            title: '',
            subtitle: '',
            hasStarted: false,
            isActive: false,
          ),
        );

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
      _liveActivityManager.updateLiveActivity(
        activityModel: LiveActivityModel(
          elapsedSeconds: timeSpent.inSeconds,
          title: state.title,
        ).toMap(),
      );
    } catch (e) {
      print('Cannot load timer data: $e');
    }
  }

  Future<void> reset() async {
    await _timerRepository.reset();
    _liveActivityManager.stopLiveActivity();
  }

  Future<void> start() async {
    await _timerRepository.startTimer(startTime: DateTime.now());
    _liveActivityManager.startLiveActivity(
      activityModel: LiveActivityModel(
        elapsedSeconds: 0,
        title: state.title,
      ).toMap(),
    );
    await updateState();
  }

  Future<void> stop() async {
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    _liveActivityManager.stopLiveActivity();
    await updateState();
  }

  Future<void> finish() async {
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    _liveActivityManager.stopLiveActivity();
    await updateState();
    emitEffect(const TimerEffect.finish());
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
