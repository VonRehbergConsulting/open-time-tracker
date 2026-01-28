import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

part 'work_packages_list_bloc.freezed.dart';

@freezed
class WorkPackagesListState with _$WorkPackagesListState {
  const factory WorkPackagesListState.loading() = _Loading;
  const factory WorkPackagesListState.idle({
    required List<WorkPackage> workPackages,
  }) = _Idle;
}

@freezed
class WorkPackagesListEffect with _$WorkPackagesListEffect {
  const factory WorkPackagesListEffect.complete({
    required bool isViewingToday,
  }) = _Complete;
  const factory WorkPackagesListEffect.error() = _Error;
}

class WorkPackagesListBloc
    extends EffectCubit<WorkPackagesListState, WorkPackagesListEffect>
    with WidgetsBindingObserver {
  final WorkPackagesRepository _workPackagesRepository;
  final AppStateRepository _appStateRepository;
  final TimerRepository _timerRepository;
  final SettingsRepository _settingsRepository;
  late String _projectId;

  WorkPackagesListBloc(
    this._workPackagesRepository,
    this._appStateRepository,
    this._timerRepository,
    this._settingsRepository,
  ) : super(const WorkPackagesListState.loading()) {
    WidgetsBinding.instance.addObserver(this);
  }

  setProject(String projectId) {
    _projectId = projectId;
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
        emit(const WorkPackagesListState.loading());
      }

      final statuses = await _settingsRepository.workPackagesStatusFilter;
      final assigneeFilter = await _settingsRepository.assigneeFilter;

      final List<WorkPackage> items = await _workPackagesRepository.list(
        projectId: _projectId,
        pageSize: 200,
        statuses: statuses,
        user: assigneeFilter == 0 ? 'me' : null,
      );
      emit(WorkPackagesListState.idle(workPackages: items));
    } catch (e) {
      emit(const WorkPackagesListState.idle(workPackages: []));
      emitEffect(const WorkPackagesListEffect.error());
    }
  }

  Future<void> setTimeEntry(WorkPackage workPackage) async {
    try {
      final selectedDate = await _appStateRepository.selectedDate;
      final timeEntry = TimeEntry.fromWorkPackage(
        workPackage,
        selectedDate: selectedDate,
      );
      await _timerRepository.setTimeEntry(timeEntry: timeEntry);

      // Wait for timer state to propagate through the stream
      // This ensures the AppAuthorizedRouter receives the update before navigation
      await _timerRepository
          .observeIsSet()
          .firstWhere((isSet) => isSet == true)
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              print('Warning: Timer state confirmation timed out');
              return true;
            },
          );

      // Determine if we're viewing today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isViewingToday =
          selectedDate == null ||
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day) ==
              today;

      emitEffect(
        WorkPackagesListEffect.complete(isViewingToday: isViewingToday),
      );
    } catch (e) {
      emitEffect(const WorkPackagesListEffect.error());
    }
  }
}
