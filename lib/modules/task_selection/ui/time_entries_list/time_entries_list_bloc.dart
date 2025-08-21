import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:collection/collection.dart';

import '../../../calendar/domain/calendar_notifications_service.dart';

part 'time_entries_list_bloc.freezed.dart';

@freezed
class TimeEntriesListState with _$TimeEntriesListState {
  const factory TimeEntriesListState.loading() = _Loading;
  const factory TimeEntriesListState.idle({
    required Map<DateTime, List<TimeEntry>> timeEntries,
    required Duration workingHours,
    required Duration totalDuration,
  }) = _Idle;
}

@freezed
class TimeEntriesListEffect with _$TimeEntriesListEffect {
  const factory TimeEntriesListEffect.error() = _Error;
}

class TimeEntriesListBloc
    extends EffectCubit<TimeEntriesListState, TimeEntriesListEffect>
    with WidgetsBindingObserver {
  final TimeEntriesRepository _timeEntriesRepository;
  final SettingsRepository _settingsRepository;
  final AuthService _authService;
  final AuthService _graphAuthService;
  final TimerRepository _timerRepository;
  final CalendarNotificationsService _calendarNotificationsService;

  TimeEntriesListBloc(
    this._timeEntriesRepository,
    this._settingsRepository,
    this._authService,
    this._graphAuthService,
    this._timerRepository,
    this._calendarNotificationsService,
  ) : super(const TimeEntriesListState.loading()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reload(showLoading: true);
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> reload({bool showLoading = false}) async {
    try {
      if (showLoading) {
        emit(const TimeEntriesListState.loading());
      }
      final items = await _timeEntriesRepository.list(userId: 'me');
      final mappedItems = items.groupListsBy(
        (elements) =>
            DateTime.parse(DateFormat('yyyy-MM-dd').format(elements.spentOn)),
      );
      final workingHours = await _settingsRepository.workingHours;
      emit(
        TimeEntriesListState.idle(
          workingHours: workingHours,
          timeEntries: mappedItems,
          totalDuration: _totalDuration(mappedItems),
        ),
      );
    } catch (e) {
      emit(
        TimeEntriesListState.idle(
          timeEntries: {},
          workingHours: const Duration(),
          totalDuration: const Duration(),
        ),
      );
      emitEffect(const TimeEntriesListEffect.error());
    }
  }

  Future<void> updateWorkingHours(Duration value) async {
    await _settingsRepository.setWorkingHours(value);
    state.whenOrNull(
      idle: (timeEntries, workingHours, totalDuration) {
        emit(
          TimeEntriesListState.idle(
            timeEntries: timeEntries,
            workingHours: value,
            totalDuration: totalDuration,
          ),
        );
      },
    );
  }

  Future<void> unauthorize() async {
    await Future.wait([
      _calendarNotificationsService.removeNotifications(),
      _graphAuthService.logout(),
    ]);
    await _authService.logout();
  }

  Future<void> setTimeEntry(TimeEntry timeEntry) async {
    await _timerRepository.setTimeEntry(timeEntry: timeEntry);
  }

  Future<bool> deleteTimeEntry(int id) async {
    if (state is _Idle) {
      final idleState = state as _Idle;
      try {
        await _timeEntriesRepository.delete(id: id);
        idleState.timeEntries.forEach((key, value) {
          value.removeWhere((element) => element.id == id);
        });
        Future.delayed(const Duration(milliseconds: 250)).then((value) {
          emit(
            TimeEntriesListState.idle(
              workingHours: idleState.workingHours,
              timeEntries: idleState.timeEntries,
              totalDuration: idleState.totalDuration,
            ),
          );
        });
        return true;
      } catch (e) {
        emitEffect(const TimeEntriesListEffect.error());
        return false;
      }
    } else {
      return false;
    }
  }

  Duration _totalDuration(Map<DateTime, List<TimeEntry>> items) {
    final todaysItems = items.entries.firstOrNull?.value ?? [];
    var result = const Duration();
    for (var element in todaysItems) {
      result += element.hours;
    }
    return result;
  }
}
