import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

import '../../../calendar/domain/calendar_notifications_service.dart';

part 'time_entries_list_bloc.freezed.dart';

@freezed
class TimeEntriesListState with _$TimeEntriesListState {
  const factory TimeEntriesListState.loading() = _Loading;
  const factory TimeEntriesListState.idle({
    required List<TimeEntry> timeEntries,
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

  List<TimeEntry> items = [];
  Duration workingHours = const Duration(hours: 0);
  Duration get totalDuration {
    var result = const Duration();
    for (var element in items) {
      result += element.hours;
    }
    return result;
  }

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

  Future<void> reload({
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        emit(const TimeEntriesListState.loading());
      }
      items = await _timeEntriesRepository.list(
        userId: 'me',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
      workingHours = await _settingsRepository.workingHours;
      emit(TimeEntriesListState.idle(
        workingHours: workingHours,
        timeEntries: items,
        totalDuration: totalDuration,
      ));
    } catch (e) {
      emit(TimeEntriesListState.idle(
        workingHours: workingHours,
        timeEntries: [],
        totalDuration: const Duration(),
      ));
      emitEffect(const TimeEntriesListEffect.error());
    }
  }

  Future<void> updateWorkingHours(Duration value) async {
    await _settingsRepository.setWorkingHours(value);
    workingHours = value;
    emit(TimeEntriesListState.idle(
      workingHours: workingHours,
      timeEntries: items,
      totalDuration: totalDuration,
    ));
  }

  Future<void> unauthorize() async {
    await Future.wait([
      _calendarNotificationsService.removeNotifications(),
      _graphAuthService.logout(),
    ]);
    await _authService.logout();
  }

  Future<void> setTimeEntry(
    TimeEntry timeEntry,
  ) async {
    await _timerRepository.setTimeEntry(
      timeEntry: timeEntry,
    );
  }

  Future<bool> deleteTimeEntry(int id) async {
    try {
      await _timeEntriesRepository.delete(id: id);
      items.removeWhere((element) => element.id == id);

      Future.delayed(const Duration(milliseconds: 250)).then((value) {
        emit(TimeEntriesListState.idle(
          workingHours: workingHours,
          timeEntries: items,
          totalDuration: totalDuration,
        ));
      });
      return true;
    } catch (e) {
      emitEffect(const TimeEntriesListEffect.error());
      return false;
    }
  }
}
