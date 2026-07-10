import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/live_activity_coordinator.dart';

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
  const factory TimerEffect.error() = _Error;
}

class TimerBloc extends EffectCubit<TimerState, TimerEffect> {
  final TimerRepository _timerRepository;
  final LiveActivityCoordinator _liveActivityCoordinator;
  Timer? _uiTicker;
  StreamSubscription<bool>? _timerStateSubscription;
  Future<void> _actionQueue = Future.value();
  bool _isTickerUpdatePending = false;

  Locale? _cachedLocale;
  AppLocalizations? _cachedL10n;

  AppLocalizations _l10n() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final cached = _cachedL10n;
    if (cached != null && _cachedLocale == deviceLocale) {
      return cached;
    }
    final resolvedLocale = basicLocaleListResolution([
      deviceLocale,
    ], AppLocalizations.supportedLocales);
    final resolved = lookupAppLocalizations(resolvedLocale);
    _cachedLocale = deviceLocale;
    _cachedL10n = resolved;
    return resolved;
  }

  TimerBloc(this._timerRepository, this._liveActivityCoordinator)
    : super(
        const TimerState.idle(
          timeSpent: Duration(),
          title: '',
          subtitle: '',
          hasStarted: false,
          isActive: false,
        ),
      ) {
    _timerStateSubscription = _timerRepository.observeIsSet().listen((_) {
      unawaited(
        updateState().catchError(
          (error) => debugPrint(
            'TimerBloc: failed to react to timer state change: $error',
          ),
        ),
      );
    });
  }

  /// Enqueues [action] on the single mutation/read queue so that every
  /// repository + live-activity + emit round-trip runs sequentially.
  ///
  /// When [label] is provided, any exception thrown by [action] is
  /// surfaced to the UI via [TimerEffect.error] in addition to being
  /// logged, so user-triggered failures are not silent.
  Future<void> _enqueue(
    Future<void> Function() action, {
    String? label,
  }) {
    final next = _actionQueue.then((_) async {
      try {
        await action();
      } catch (error, stackTrace) {
        debugPrint(
          'TimerBloc: ${label ?? 'action'} failed: $error\n$stackTrace',
        );
        if (label != null && !isClosed) {
          emitEffect(const TimerEffect.error());
        }
        rethrow;
      }
    });
    _actionQueue = next.catchError((_) {});
    return next;
  }

  Future<void> updateState() => _enqueue(_updateStateInternal);

  Future<void> _updateStateInternal() async {
    try {
      final data = await Future.wait([
        _timerRepository.timeEntry,
        _timerRepository.hasStarted,
        _timerRepository.isActive,
        _timerRepository.timeSpent,
      ]);

      final timeEntry = data[0] as TimeEntry?;
      if (timeEntry == null) {
        _syncUiTicker(false);
        await _liveActivityCoordinator.stop();

        if (isClosed) {
          return;
        }

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
      _syncUiTicker(isActive);

      await _liveActivityCoordinator.sync(
        isActive: isActive,
        timeSpent: timeSpent,
        timeEntry: timeEntry,
        inProgressTag: _l10n().generic__in_progress,
      );

      if (isClosed) {
        return;
      }

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
      debugPrint('Cannot load timer data: $e');
    }
  }

  void _syncUiTicker(bool isActive) {
    if (isActive) {
      _uiTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        // Drop ticks if a previous update is still in flight to avoid
        // unbounded queue growth if the pipeline takes >1s.
        if (_isTickerUpdatePending || isClosed) {
          return;
        }
        _isTickerUpdatePending = true;
        unawaited(
          updateState()
              .catchError(
                (error) => debugPrint(
                  'TimerBloc: ticker update failed: $error',
                ),
              )
              .whenComplete(() => _isTickerUpdatePending = false),
        );
      });
      return;
    }

    _uiTicker?.cancel();
    _uiTicker = null;
  }

  Future<void> reset() => _enqueue(_resetInternal, label: 'reset');

  Future<void> _resetInternal() async {
    _syncUiTicker(false);
    await _timerRepository.reset();
    await _liveActivityCoordinator.stop();
    await _updateStateInternal();
  }

  Future<void> start() => _enqueue(_startInternal, label: 'start');

  Future<void> _startInternal() async {
    await _timerRepository.startTimer(startTime: DateTime.now());
    _syncUiTicker(true);

    final timeSpent = await _timerRepository.timeSpent;
    final timeEntry = await _timerRepository.timeEntry;
    if (timeEntry != null) {
      await _liveActivityCoordinator.start(
        timeSpent: timeSpent,
        timeEntry: timeEntry,
        inProgressTag: _l10n().generic__in_progress,
      );
    }

    await _updateStateInternal();
  }

  Future<void> stop() => _enqueue(_stopInternal, label: 'stop');

  Future<void> _stopInternal() async {
    _syncUiTicker(false);
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    await _liveActivityCoordinator.stop();
    await _updateStateInternal();
  }

  Future<void> finish() => _enqueue(_finishInternal, label: 'finish');

  Future<void> _finishInternal() async {
    _syncUiTicker(false);
    await _timerRepository.stopTimer(stopTime: DateTime.now());
    await _liveActivityCoordinator.stop();
    await _updateStateInternal();
    if (!isClosed) {
      emitEffect(const TimerEffect.finish());
    }
  }

  Future<void> add(Duration duration) =>
      _enqueue(() => _addInternal(duration), label: 'add');

  Future<void> _addInternal(Duration duration) async {
    await _timerRepository.add(duration);
    final timeEntry = await _timerRepository.timeEntry;

    await _liveActivityCoordinator.add(
      duration: duration,
      timeEntry: timeEntry,
      inProgressTag: _l10n().generic__in_progress,
    );

    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(timeSpent: state.timeSpent + duration, hasStarted: true),
    );
  }

  @override
  Future<void> close() {
    _syncUiTicker(false);
    _timerStateSubscription?.cancel();
    return super.close();
  }
}
