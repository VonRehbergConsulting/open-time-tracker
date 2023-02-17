import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
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
  const factory WorkPackagesListEffect.complete() = _Complete;
  const factory WorkPackagesListEffect.error({
    required String message,
  }) = _Error;
}

class WorkPackagesListBloc
    extends EffectCubit<WorkPackagesListState, WorkPackagesListEffect> {
  WorkPackagesRepository _workPackagesRepository;
  UserDataRepository _userDataRepository;
  TimerRepository _timerRepository;

  WorkPackagesListBloc(
    this._workPackagesRepository,
    this._userDataRepository,
    this._timerRepository,
  ) : super(WorkPackagesListState.loading());

  Future<void> reload({
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        emit(WorkPackagesListState.loading());
      }
      final items = await _workPackagesRepository.list(
        userId: _userDataRepository.userID,
      );
      emit(WorkPackagesListState.idle(
        workPackages: items,
      ));
    } catch (e) {
      emitEffect(WorkPackagesListEffect.error(message: 'Something went wrong'));
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
      emitEffect(WorkPackagesListEffect.complete());
    } catch (e) {
      emitEffect(WorkPackagesListEffect.error(message: 'Something went wrong'));
    }
  }
}
