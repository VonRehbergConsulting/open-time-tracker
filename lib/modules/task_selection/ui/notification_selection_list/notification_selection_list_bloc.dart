import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';

import '../../../timer/domain/timer_repository.dart';
import '../../domain/time_entries_repository.dart';
import '../../domain/work_packages_repository.dart';

part 'notification_selection_list_bloc.freezed.dart';

@freezed
class NotificationSelectionListState with _$NotificationSelectionListState {
  const factory NotificationSelectionListState.loading() = _Loading;
  const factory NotificationSelectionListState.idle({
    required List<TimeEntry> timeEntries,
    required List<WorkPackage> workPackages,
  }) = _Idle;
}

@freezed
class NotificationSelectionListEffect with _$NotificationSelectionListEffect {
  const factory NotificationSelectionListEffect.error() = _Error;
  const factory NotificationSelectionListEffect.complete() = _Complete;
}

class NotificationSelectionListBloc extends EffectCubit<
    NotificationSelectionListState,
    NotificationSelectionListEffect> with WidgetsBindingObserver {
  final WorkPackagesRepository _workPackagesRepository;
  final TimerRepository _timerRepository;
  final TimeEntriesRepository _timeEntriesRepository;

  NotificationSelectionListBloc(
    this._workPackagesRepository,
    this._timerRepository,
    this._timeEntriesRepository,
  ) : super(const NotificationSelectionListState.loading()) {
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
        emit(const NotificationSelectionListState.loading());
      }
      final data = await Future.wait([
        _timeEntriesRepository.list(
          userId: 'me',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        _workPackagesRepository.list(
          pageSize: 100,
        ),
      ]);
      emit(NotificationSelectionListState.idle(
        timeEntries: data[0] as List<TimeEntry>,
        workPackages: data[1] as List<WorkPackage>,
      ));
    } catch (e) {
      emit(const NotificationSelectionListState.idle(
        timeEntries: [],
        workPackages: [],
      ));
      emitEffect(const NotificationSelectionListEffect.error());
    }
  }

  Future<void> setTimeEntry(
    TimeEntry timeEntry,
  ) async {
    await _timerRepository.setTimeEntry(
      timeEntry: timeEntry,
    );
    emitEffect(const NotificationSelectionListEffect.complete());
  }

  Future<void> setTimeEntryFromWorkPackage(
    WorkPackage workPackage,
  ) async {
    try {
      final timeEntry = TimeEntry.fromWorkPackage(workPackage);
      await _timerRepository.setTimeEntry(
        timeEntry: timeEntry,
      );
      emitEffect(const NotificationSelectionListEffect.complete());
    } catch (e) {
      emitEffect(const NotificationSelectionListEffect.error());
    }
  }
}
