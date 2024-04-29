import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/groups_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

part 'work_packages_list_bloc.freezed.dart';

enum WorkPackagesListDataSource {
  user,
  groups,
}

@freezed
class WorkPackagesListState with _$WorkPackagesListState {
  const factory WorkPackagesListState.loading({
    required WorkPackagesListDataSource dataSource,
  }) = _Loading;
  const factory WorkPackagesListState.idle({
    required Map<String, List<WorkPackage>> workPackages,
    required WorkPackagesListDataSource dataSource,
  }) = _Idle;
}

@freezed
class WorkPackagesListEffect with _$WorkPackagesListEffect {
  const factory WorkPackagesListEffect.complete() = _Complete;
  const factory WorkPackagesListEffect.error() = _Error;
}

class WorkPackagesListBloc
    extends EffectCubit<WorkPackagesListState, WorkPackagesListEffect>
    with WidgetsBindingObserver {
  final WorkPackagesRepository _workPackagesRepository;
  final UserDataRepository _userDataRepository;
  final TimerRepository _timerRepository;
  final SettingsRepository _settingsRepository;
  final GroupsRepository _groupsRepository;

  WorkPackagesListDataSource _dataSource = WorkPackagesListDataSource.user;

  WorkPackagesListBloc(
    this._workPackagesRepository,
    this._userDataRepository,
    this._timerRepository,
    this._settingsRepository,
    this._groupsRepository,
  ) : super(const WorkPackagesListState.loading(
          dataSource: WorkPackagesListDataSource.user,
        )) {
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
    WorkPackagesListDataSource? newDataSource,
  }) async {
    try {
      if (newDataSource != null) {
        _dataSource = newDataSource;
      }
      if (showLoading) {
        emit(WorkPackagesListState.loading(
          dataSource: _dataSource,
        ));
      }

      final statuses = await _settingsRepository.workPackagesStatusFilter;
      final List<WorkPackage> items;
      switch (_dataSource) {
        case WorkPackagesListDataSource.user:
          items = await _fetchUserWorkPackages(statuses);
          break;
        case WorkPackagesListDataSource.groups:
          items = await _fetchGroupsWorkPackages(statuses);
          break;
      }

      emit(WorkPackagesListState.idle(
        workPackages: _groupByProject(items),
        dataSource: _dataSource,
      ));
    } catch (e) {
      emit(WorkPackagesListState.idle(
        workPackages: {},
        dataSource: _dataSource,
      ));
      emitEffect(const WorkPackagesListEffect.error());
    }
  }

  Future<void> setTimeEntry(
    WorkPackage workPackage,
  ) async {
    try {
      final timeEntry = TimeEntry.fromWorkPackage(workPackage);
      await _timerRepository.setTimeEntry(
        timeEntry: timeEntry,
      );
      emitEffect(const WorkPackagesListEffect.complete());
    } catch (e) {
      emitEffect(const WorkPackagesListEffect.error());
    }
  }

  Future<List<WorkPackage>> _fetchUserWorkPackages(Set<int> statuses) async {
    return await _workPackagesRepository.list(
      userId: _userDataRepository.userID,
      pageSize: 100,
      statuses: statuses,
    );
  }

  Future<List<WorkPackage>> _fetchGroupsWorkPackages(Set<int> statuses) async {
    final groups = await _groupsRepository.list(
      pageSize: 100,
    );
    // endpoint doesn't support filtering, so it's being filtered here
    final filteredGroups = groups.where(
        (element) => element.memberIds.contains(_userDataRepository.userID));

    List<WorkPackage> result = [];
    for (var group in filteredGroups) {
      final response = await _workPackagesRepository.list(
        userId: group.id,
        pageSize: 100,
        statuses: statuses,
      );
      result.addAll(response);
    }
    return result;
  }

  Map<String, List<WorkPackage>> _groupByProject(
      List<WorkPackage> workPackages) {
    Map<String, List<WorkPackage>> result = {};
    for (final workPackage in workPackages) {
      final project = workPackage.projectTitle;
      if (result[project] != null) {
        result[project]!.add(workPackage);
      } else {
        result[project] = [workPackage];
      }
    }
    return result;
  }
}
