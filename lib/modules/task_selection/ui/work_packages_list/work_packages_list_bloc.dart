import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/extensions/date_time.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/task_filter_repository.dart';
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
    required TimeEntry timeEntry,
  }) = _Complete;
  const factory WorkPackagesListEffect.error() = _Error;
}

class WorkPackagesListBloc
    extends EffectCubit<WorkPackagesListState, WorkPackagesListEffect>
    with WidgetsBindingObserver {
  final WorkPackagesRepository _workPackagesRepository;
  final AppStateRepository _appStateRepository;
  final TimerRepository _timerRepository;
  final TaskFilterRepository _taskFilter;
  late String _projectId;
  CancelToken? _cancelToken;

  WorkPackagesListBloc(
    this._workPackagesRepository,
    this._appStateRepository,
    this._timerRepository,
    this._taskFilter,
  ) : super(const WorkPackagesListState.loading()) {
    WidgetsBinding.instance.addObserver(this);
  }

  void setProject(String projectId) {
    _projectId = projectId;
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelToken?.cancel('Bloc closed');
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
    // Cancel any previous reload operation
    _cancelToken?.cancel('New reload started');
    _cancelToken = CancelToken();

    try {
      if (showLoading) {
        emit(const WorkPackagesListState.loading());
      }

      final statuses = await _taskFilter.workPackagesStatusFilter;
      final assigneeFilter = await _taskFilter.assigneeFilter;

      final List<WorkPackage> items = await _workPackagesRepository.list(
        projectId: _projectId,
        pageSize: 200,
        statuses: statuses,
        user: assigneeFilter == 0 ? 'me' : null,
      );

      // Only emit if not cancelled
      if (!_cancelToken!.isCancelled) {
        emit(WorkPackagesListState.idle(workPackages: items));
      }
    } on DioException catch (e) {
      // Ignore cancellation errors
      if (CancelToken.isCancel(e)) {
        debugPrint('WorkPackagesListBloc: reload cancelled');
        return;
      }
      emit(const WorkPackagesListState.idle(workPackages: []));
      emitEffect(const WorkPackagesListEffect.error());
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

      final isViewingToday = selectedDate == null || selectedDate.isToday;

      if (isViewingToday) {
        await _timerRepository.setTimeEntry(timeEntry: timeEntry);

        await _timerRepository
            .observeIsSet()
            .firstWhere((isSet) => isSet == true)
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                debugPrint(
                  'WorkPackagesListBloc: timer state confirmation timed out',
                );
                return true;
              },
            );
      }

      emitEffect(
        WorkPackagesListEffect.complete(
          isViewingToday: isViewingToday,
          timeEntry: timeEntry,
        ),
      );
    } catch (e) {
      emitEffect(const WorkPackagesListEffect.error());
    }
  }
}
