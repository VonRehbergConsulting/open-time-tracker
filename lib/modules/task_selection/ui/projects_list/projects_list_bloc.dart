import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';

part 'projects_list_bloc.freezed.dart';

@freezed
class ProjectsListState with _$ProjectsListState {
  const factory ProjectsListState.loading() = _Loading;
  const factory ProjectsListState.idle({
    required List<Project> projects,
  }) = _Idle;
}

@freezed
class ProjectsListEffect with _$ProjectsListEffect {
  const factory ProjectsListEffect.error() = _Error;
}

class ProjectsListBloc
    extends EffectCubit<ProjectsListState, ProjectsListEffect> {
  final ProjectsRepository _projectsRepository;

  ProjectsListBloc(
    this._projectsRepository,
  ) : super(const ProjectsListState.loading());

  Future<void> reload() async {
    final projects = await _projectsRepository.list(
      active: true,
      pageSize: 200,
    );
    emit(
      ProjectsListState.idle(
        projects: projects,
      ),
    );
  }
}
