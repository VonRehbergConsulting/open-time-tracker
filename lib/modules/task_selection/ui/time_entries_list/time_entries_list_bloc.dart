import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

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
  TimeEntriesRepository _timeEntriesRepository;
  UserDataRepository _userDataRepository;
  SettingsRepository _settingsRepository;
  AuthService _authService;
  TimerRepository _timerRepository;

  List<TimeEntry> items = [];
  Duration workingHours = Duration(hours: 0);
  Duration get totalDuration {
    var result = const Duration();
    for (var element in items) {
      result += element.hours;
    }
    return result;
  }

  TimeEntriesListBloc(
    this._timeEntriesRepository,
    this._userDataRepository,
    this._settingsRepository,
    this._authService,
    this._timerRepository,
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
        emit(TimeEntriesListState.loading());
      }
      items = await _timeEntriesRepository.list(
        userId: _userDataRepository.userID,
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
        totalDuration: Duration(),
      ));
      emitEffect(TimeEntriesListEffect.error());
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

      Future.delayed(Duration(milliseconds: 250)).then((value) {
        emit(TimeEntriesListState.idle(
          workingHours: workingHours,
          timeEntries: items,
          totalDuration: totalDuration,
        ));
      });
      return true;
    } catch (e) {
      emitEffect(TimeEntriesListEffect.error());
      return false;
    }
  }
}
