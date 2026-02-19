import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
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
    required DateTime selectedDate,
    required bool isViewingToday,
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
  final AppStateRepository _appStateRepository;
  final TimerRepository _timerRepository;
  final CalendarNotificationsService _calendarNotificationsService;

  List<TimeEntry> items = [];
  Duration workingHours = const Duration(hours: 0);
  late DateTime selectedDate;
  bool _isInitialized = false;

  bool get isViewingToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    return selected == today;
  }

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
    this._appStateRepository,
    this._timerRepository,
    this._calendarNotificationsService,
  ) : super(const TimeEntriesListState.loading()) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    // Always default to today when the app starts
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    await _appStateRepository.setSelectedDate(selectedDate);
    _isInitialized = true;
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
      // Wait for initialization to complete before reloading
      if (!_isInitialized) {
        await _initialize();
      }

      if (showLoading) {
        emit(const TimeEntriesListState.loading());
      }
      final dateOnly = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      items = await _timeEntriesRepository.list(
        userId: 'me',
        startDate: dateOnly,
        endDate: dateOnly,
      );
      workingHours = await _settingsRepository.workingHours;
      emit(
        TimeEntriesListState.idle(
          workingHours: workingHours,
          timeEntries: items,
          totalDuration: totalDuration,
          selectedDate: selectedDate,
          isViewingToday: isViewingToday,
        ),
      );
    } catch (e) {
      emit(
        TimeEntriesListState.idle(
          workingHours: workingHours,
          timeEntries: [],
          totalDuration: const Duration(),
          selectedDate: selectedDate,
          isViewingToday: isViewingToday,
        ),
      );
      emitEffect(const TimeEntriesListEffect.error());
    }
  }

  Future<void> updateWorkingHours(Duration value) async {
    await _settingsRepository.setWorkingHours(value);
    workingHours = value;
    emit(
      TimeEntriesListState.idle(
        workingHours: workingHours,
        timeEntries: items,
        totalDuration: totalDuration,
        selectedDate: selectedDate,
        isViewingToday: isViewingToday,
      ),
    );
  }

  Future<void> changeDate(DateTime newDate) async {
    selectedDate = DateTime(newDate.year, newDate.month, newDate.day);
    await _appStateRepository.setSelectedDate(selectedDate);
    await reload(showLoading: true);
  }

  Future<void> goToPreviousDay() async {
    selectedDate = selectedDate.subtract(const Duration(days: 1));
    await _appStateRepository.setSelectedDate(selectedDate);
    await reload(showLoading: true);
  }

  Future<void> goToNextDay() async {
    selectedDate = selectedDate.add(const Duration(days: 1));
    await _appStateRepository.setSelectedDate(selectedDate);
    await reload(showLoading: true);
  }

  Future<void> unauthorize() async {
    await Future.wait([
      _calendarNotificationsService.removeNotifications(),
      _graphAuthService.logout(),
    ]);
    await _authService.logout();
  }

  Future<void> setTimeEntry(TimeEntry timeEntry) async {
    // Update the spentOn date to match the currently selected date
    // This ensures that when tracking time for a past or future date,
    // the time entry is recorded for that specific date
    timeEntry.spentOn = selectedDate;
    await _timerRepository.setTimeEntry(timeEntry: timeEntry);
  }

  Future<bool> deleteTimeEntry(int id) async {
    try {
      await _timeEntriesRepository.delete(id: id);
      items.removeWhere((element) => element.id == id);

      Future.delayed(const Duration(milliseconds: 250)).then((value) {
        emit(
          TimeEntriesListState.idle(
            workingHours: workingHours,
            timeEntries: items,
            totalDuration: totalDuration,
            selectedDate: selectedDate,
            isViewingToday: isViewingToday,
          ),
        );
      });
      return true;
    } catch (e) {
      emitEffect(const TimeEntriesListEffect.error());
      return false;
    }
  }

  void addTimeEntry(TimeEntry timeEntry) {
    // Add the newly created entry to the local list (optimistic update)
    items.add(timeEntry);
    emit(
      TimeEntriesListState.idle(
        workingHours: workingHours,
        timeEntries: items,
        totalDuration: totalDuration,
        selectedDate: selectedDate,
        isViewingToday: isViewingToday,
      ),
    );
  }

  void updateTimeEntry(TimeEntry updatedEntry) {
    // Update the entry in the local list (optimistic update)
    final index = items.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      items[index] = updatedEntry;
      emit(
        TimeEntriesListState.idle(
          workingHours: workingHours,
          timeEntries: items,
          totalDuration: totalDuration,
          selectedDate: selectedDate,
          isViewingToday: isViewingToday,
        ),
      );
    }
  }
}
