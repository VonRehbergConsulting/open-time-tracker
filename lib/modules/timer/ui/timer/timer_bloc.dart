import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';
import 'package:open_project_time_tracker/app/live_activity/infrastructure/default_live_activity_manager.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
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

  // Track when the current live activity session started
  DateTime? _liveActivitySessionStart;
  // Track current task to detect task switches
  String? _currentTaskTitle;

  AppLocalizations _l10n() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final resolvedLocale = basicLocaleListResolution([
      deviceLocale,
    ], AppLocalizations.supportedLocales);

    return lookupAppLocalizations(resolvedLocale);
  }

  TimerBloc(this._timerRepository, this._liveActivityManager)
    : super(
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
      final timeEntry = data[0] as TimeEntry?;
      if (timeEntry == null) {
        // No task selected; ensure any running live activity is stopped
        if (_liveActivitySessionStart != null) {
          await _liveActivityManager.stopLiveActivity();
          _liveActivitySessionStart = null;
        }
        _currentTaskTitle = null;
        // Emit empty idle state
        emit(
          const TimerState.idle(
            timeSpent: Duration(),
            title: '',
            subtitle: '',
            hasStarted: false,
            isActive: false,
          ),
        );
        return;
      }

      final hasStarted = data[1] as bool;
      final isActive = data[2] as bool;
      final timeSpent = data[3] as Duration;

      // Detect task switch or timer becoming inactive while live activity is running
      if (_liveActivitySessionStart != null) {
        final taskChanged =
            _currentTaskTitle != null &&
            _currentTaskTitle != timeEntry.workPackageSubject;
        if (!isActive || taskChanged) {
          // Timer stopped or task switched, stop live activity
          await _liveActivityManager.stopLiveActivity();
          _liveActivitySessionStart = null;
          _currentTaskTitle = null;
        }
        // Note: No need to call updateLiveActivity() - the native chronometer
        // on Android and Live Activity on iOS both update themselves automatically
      }

      _currentTaskTitle = timeEntry.workPackageSubject;

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
    await _timerRepository.reset();
    await _liveActivityManager.stopLiveActivity();
    _liveActivitySessionStart = null;
    _currentTaskTitle = null;
  }

  Future<void> start() async {
    await _timerRepository.startTimer(startTime: DateTime.now());

    // Get the actual time spent to handle resume correctly
    final timeSpent = await _timerRepository.timeSpent;

    // Calculate session start: if resuming (timeSpent > 0), offset by existing time
    // This ensures the live activity continues from where it left off, not from 0:00:00
    _liveActivitySessionStart = DateTime.now().add(-timeSpent);

    // Live activity should show current session time only, not accumulated time from other tasks
    try {
      await _liveActivityManager.startLiveActivity(
        activityModel: LiveActivityModel(
          startTimestamp:
              (_liveActivitySessionStart!.millisecondsSinceEpoch / 1000)
                  .round(),
          title: state.title,
          subtitle: state.subtitle,
          tag: _l10n().generic__in_progress,
        ).toMap(),
      );
    } on LiveActivityPermissionException catch (e) {
      // Permission was denied - live activity won't be shown, but timer still works
      // The proactive permission check in TimerPage should prevent this scenario
      debugPrint('Live activity permission denied: ${e.message}');
      // Continue without live activity - timer functionality is not blocked
    }
    _currentTaskTitle = state.title;
    await updateState();
  }

  Future<void> stop() async {
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    await _liveActivityManager.stopLiveActivity();
    _liveActivitySessionStart = null;
    await updateState();
  }

  Future<void> finish() async {
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    await _liveActivityManager.stopLiveActivity();
    _liveActivitySessionStart = null;
    await updateState();
    emitEffect(const TimerEffect.finish());
  }

  Future<void> add(Duration duration) async {
    await _timerRepository.add(duration);
    final timeSpent = state.timeSpent + duration;
    // When manually adding time, shift the live activity session start backwards
    // so the timer shows the additional time
    if (_liveActivitySessionStart != null) {
      _liveActivitySessionStart = _liveActivitySessionStart!.add(-duration);
      try {
        await _liveActivityManager.updateLiveActivity(
          activityModel: LiveActivityModel(
            startTimestamp:
                (_liveActivitySessionStart!.millisecondsSinceEpoch / 1000)
                    .round(),
            title: state.title,
            subtitle: state.subtitle,
            tag: _l10n().generic__in_progress,
          ).toMap(),
        );
      } on LiveActivityPermissionException catch (e) {
        debugPrint('Live activity permission denied: ${e.message}');
      } catch (e) {
        debugPrint('Failed to update live activity: $e');
      }
    }
    emit(state.copyWith(timeSpent: timeSpent, hasStarted: true));
  }
}
