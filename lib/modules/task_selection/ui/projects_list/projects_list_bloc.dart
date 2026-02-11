import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';

part 'projects_list_bloc.freezed.dart';

@freezed
class ProjectsListState with _$ProjectsListState {
  const factory ProjectsListState.loading() = _Loading;
  const factory ProjectsListState.notLoaded({
    required bool showOnlyProjectsWithTasks,
    required bool doNotLoadProjectList,
    required String query,
  }) = _NotLoaded;
  const factory ProjectsListState.idle({
    required List<Project> allProjects,
    required List<Project> projects,
    required String query,
    required bool showOnlyProjectsWithTasks,
    required bool doNotLoadProjectList,
  }) = _Idle;
}

@freezed
class ProjectsListEffect with _$ProjectsListEffect {
  const factory ProjectsListEffect.error() = _Error;
}

class ProjectsListBloc
    extends EffectCubit<ProjectsListState, ProjectsListEffect> {
  final ProjectsRepository _projectsRepository;
  final SettingsRepository _settingsRepository;
  final WorkPackagesRepository _workPackagesRepository;

  String _query = '';
  bool _showOnlyProjectsWithTasks = false;
  bool _doNotLoadProjectList = false;

  ProjectsListBloc(
    this._projectsRepository,
    this._settingsRepository,
    this._workPackagesRepository,
  ) : super(const ProjectsListState.loading());

  Future<void> onPageOpened() async {
    await _loadSettings();

    // If the user opted out of loading projects automatically, show an empty
    // state that allows manual loading.
    if (_doNotLoadProjectList) {
      emit(
        ProjectsListState.notLoaded(
          showOnlyProjectsWithTasks: _showOnlyProjectsWithTasks,
          doNotLoadProjectList: _doNotLoadProjectList,
          query: _query,
        ),
      );
      return;
    }

    await reload(showLoading: true);
  }

  Future<void> _loadSettings() async {
    try {
      _showOnlyProjectsWithTasks =
          await _settingsRepository.showOnlyProjectsWithTasks;
    } catch (_) {
      _showOnlyProjectsWithTasks = false;
    }

    try {
      _doNotLoadProjectList = await _settingsRepository.doNotLoadProjectList;
    } catch (_) {
      _doNotLoadProjectList = false;
    }
  }

  void setQuery(String value) {
    _query = value;
    state.maybeWhen(
      idle: (allProjects, projects, query, showOnly, doNotLoad) {
        final filtered = _applyQuery(allProjects, _query);
        emit(
          ProjectsListState.idle(
            allProjects: allProjects,
            projects: filtered,
            query: _query,
            showOnlyProjectsWithTasks: showOnly,
            doNotLoadProjectList: doNotLoad,
          ),
        );
      },
      notLoaded: (showOnly, doNotLoad, query) {
        emit(
          ProjectsListState.notLoaded(
            showOnlyProjectsWithTasks: showOnly,
            doNotLoadProjectList: doNotLoad,
            query: _query,
          ),
        );
      },
      orElse: () {},
    );
  }

  List<Project> _applyQuery(List<Project> allProjects, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allProjects;
    return allProjects
        .where((p) => p.title.toLowerCase().contains(q))
        .toList();
  }

  String _projectKeyFromHref(String href) {
    try {
      final clean = href.split('?').first;
      return clean.split('/').where((e) => e.isNotEmpty).last;
    } catch (_) {
      return href;
    }
  }

  Future<void> reload({bool showLoading = false}) async {
    await _loadSettings();
    if (showLoading) {
      emit(const ProjectsListState.loading());
    }

    List<Project> projects = [];
    try {
      projects = await _projectsRepository.list(
        active: true,
        pageSize: 200,
        sortByName: true,
        assignedToUser: true,
      );
    } catch (e) {
      emit(
        ProjectsListState.idle(
          allProjects: const [],
          projects: const [],
          query: _query,
          showOnlyProjectsWithTasks: _showOnlyProjectsWithTasks,
          doNotLoadProjectList: _doNotLoadProjectList,
        ),
      );
      emitEffect(const ProjectsListEffect.error());
      return;
    }

    var filteredProjects = projects;

    if (_showOnlyProjectsWithTasks) {
      try {
        final statuses = await _settingsRepository.workPackagesStatusFilter;
        final assigneeFilter = await _settingsRepository.assigneeFilter;

        // NOTE: OpenProject API is paginated. We request a large page size to
        // keep this feature simple and avoid multiple requests. If the instance
        // has more work packages than this limit, the filter may be incomplete.
        final workPackages = await _workPackagesRepository.list(
          projectId: null,
          pageSize: 1000,
          statuses: statuses,
          user: assigneeFilter == 0 ? 'me' : null,
        );

        final projectKeys = workPackages
            .map((wp) => _projectKeyFromHref(wp.projectHref))
            .toSet();
        final projectTitles = workPackages.map((wp) => wp.projectTitle).toSet();

        filteredProjects = projects
            .where(
              (p) => projectKeys.contains(p.id) || projectTitles.contains(p.title),
            )
            .toList();
      } catch (e) {
        // If filtering fails, fall back to the unfiltered list.
        filteredProjects = projects;
      }
    }

    final visible = _applyQuery(filteredProjects, _query);

    emit(
      ProjectsListState.idle(
        allProjects: filteredProjects,
        projects: visible,
        query: _query,
        showOnlyProjectsWithTasks: _showOnlyProjectsWithTasks,
        doNotLoadProjectList: _doNotLoadProjectList,
      ),
    );
  }
}
