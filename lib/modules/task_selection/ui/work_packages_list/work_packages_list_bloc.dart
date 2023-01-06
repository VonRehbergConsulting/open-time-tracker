import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';

part 'work_packages_list_bloc.freezed.dart';

@freezed
class WorkPackagesListState with _$WorkPackagesListState {
  const factory WorkPackagesListState.loading() = _Loading;
  const factory WorkPackagesListState.idle({
    required List<WorkPackage> workPackages,
  }) = _Idle;
}

class WorkPackagesListBloc extends Cubit<WorkPackagesListState> {
  WorkPackagesRepository _workPackagesRepository;
  UserDataRepository _userDataRepository;

  WorkPackagesListBloc(
    this._workPackagesRepository,
    this._userDataRepository,
  ) : super(WorkPackagesListState.loading());

  Future<void> reload() async {
    try {
      final items = await _workPackagesRepository.list(
        userId: _userDataRepository.userID,
      );
      emit(WorkPackagesListState.idle(
        workPackages: items,
      ));
    } catch (e) {
      // TODO: show error
    }
  }
}
