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
    ]);
    final statuses = responces[0] as List<Status>;
    var selectedIds = responces[1] as Set<int>;

    // filter out non-existent statuses in case they were changed
    selectedIds = await _checkStatusesExistance(statuses, selectedIds);

    emit(WorkpackagesFilterState.selection(
      statuses: statuses,
      selectedIds: selectedIds,
    ));
  }

  Future<void> toggleSelection(int id) async {
    state.whenOrNull(
      selection: (statuses, selectedIds) async {
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
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    state.whenOrNull(selection: (statuses, selectedIds) async {
      await _settingsRepository.setWorkPackagesStatusFilter(selectedIds);
      emitEffect(const WorkPackagesFilterEffect.complete());
    });
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
