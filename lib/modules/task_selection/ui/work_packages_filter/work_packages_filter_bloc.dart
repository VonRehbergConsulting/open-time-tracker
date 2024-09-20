import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/effect_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/statuses_repository.dart';

part 'work_packages_filter_bloc.freezed.dart';

@freezed
class WorkpackagesFilterState with _$WorkpackagesFilterState {
  const factory WorkpackagesFilterState.loading() = _Loading;
  const factory WorkpackagesFilterState.selection({
    required List<Status> statuses,
    required Set<int> selectedIds,
    required int assigneeFilter,
  }) = _Selection;
}

@freezed
class WorkPackagesFilterEffect with _$WorkPackagesFilterEffect {
  const factory WorkPackagesFilterEffect.complete() = _Complete;
  const factory WorkPackagesFilterEffect.error() = _Error;
}

class WorkPackagesFilterBloc
    extends EffectCubit<WorkpackagesFilterState, WorkPackagesFilterEffect> {
  final StatusesRepository _statusesRepository;
  final SettingsRepository _settingsRepository;

  WorkPackagesFilterBloc(
    this._statusesRepository,
    this._settingsRepository,
  ) : super(const WorkpackagesFilterState.loading());

  Future<void> reload() async {
    final responces = await Future.wait([
      _statusesRepository.list(),
      _settingsRepository.workPackagesStatusFilter,
      _settingsRepository.assigneeFilter,
    ]);
    final statuses = responces[0] as List<Status>;
    var selectedIds = responces[1] as Set<int>;
    final assigneeFilter = responces[2] as int;

    // filter out non-existent statuses in case they were changed
    selectedIds = await _checkStatusesExistance(statuses, selectedIds);

    emit(WorkpackagesFilterState.selection(
      statuses: statuses,
      selectedIds: selectedIds,
      assigneeFilter: assigneeFilter,
    ));
  }

  Future<void> toggleStatusSelection(int id) async {
    state.whenOrNull(
      selection: (
        statuses,
        selectedIds,
        assigneeFilter,
      ) async {
        final newSelectedIds = Set<int>.from(selectedIds);
        if (newSelectedIds.contains(id)) {
          newSelectedIds.remove(id);
        } else {
          newSelectedIds.add(id);
        }
        emit(
          WorkpackagesFilterState.selection(
            statuses: statuses,
            selectedIds: newSelectedIds,
            assigneeFilter: assigneeFilter,
          ),
        );
      },
    );
  }

  Future<void> setAssigneeFilter(int value) async {
    state.whenOrNull(
      selection: (
        statuses,
        selectedIds,
        assigneeFilter,
      ) async {
        emit(
          WorkpackagesFilterState.selection(
            statuses: statuses,
            selectedIds: selectedIds,
            assigneeFilter: value,
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    try {
      state.whenOrNull(
        selection: (
          statuses,
          selectedIds,
          assigneeFilter,
        ) async {
          await Future.wait([
            _settingsRepository.setWorkPackagesStatusFilter(selectedIds),
            _settingsRepository.setAssigneeFilter(assigneeFilter),
          ]);
        },
      );
      emitEffect(const WorkPackagesFilterEffect.complete());
    } catch (e) {
      emitEffect(const WorkPackagesFilterEffect.error());
    }
  }

  Future<Set<int>> _checkStatusesExistance(
    List<Status> statuses,
    Set<int> selectedIds,
  ) async {
    bool isChanged = false;
    final statusIds = statuses.map((e) => e.id).toList();
    for (var id in selectedIds.toList()) {
      if (!statusIds.contains(id)) {
        selectedIds.remove(id);
        isChanged = true;
      }
    }
    if (isChanged) {
      await _settingsRepository.setWorkPackagesStatusFilter(selectedIds);
      print('Non-existent statuses have been removed');
    }
    return selectedIds;
  }
}
