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
    required bool favoritesOnly,
    required String query,
  }) = _NotLoaded;
  const factory ProjectsListState.idle({
    required List<Project> allProjects,
    required List<Project> projects,
    required String query,
    required bool showOnlyProjectsWithTasks,
    required bool doNotLoadProjectList,
    required bool favoritesOnly,
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
  bool _favoritesOnly = false;

  bool _hasLoadedProjectsOnce = false;

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
          favoritesOnly: _favoritesOnly,
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
      idle: (allProjects, projects, query, showOnly, doNotLoad, favoritesOnly) {
        final filtered = _applyQuery(allProjects, _query);
        emit(
          ProjectsListState.idle(
            allProjects: allProjects,
            projects: filtered,
            query: _query,
            showOnlyProjectsWithTasks: showOnly,
            doNotLoadProjectList: doNotLoad,
            favoritesOnly: favoritesOnly,
          ),
        );
      },
      notLoaded: (showOnly, doNotLoad, favoritesOnly, query) {
        emit(
          ProjectsListState.notLoaded(
            showOnlyProjectsWithTasks: showOnly,
            doNotLoadProjectList: doNotLoad,
            favoritesOnly: favoritesOnly,
            query: _query,
          ),
        );
      },
      orElse: () {},
    );
  }


  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;

    // If projects were already loaded at least once, reload so we fetch the
    // correct server-side filtered set (favorited projects).
    if (_hasLoadedProjectsOnce) {
      reload(showLoading: true);
      return;
    }

    // Otherwise, only update the notLoaded state. In lazy-load mode, projects
    // will still be loaded on explicit search submit.
    state.maybeWhen(
      notLoaded: (showOnly, doNotLoad, favoritesOnly, query) {
        emit(
          ProjectsListState.notLoaded(
            showOnlyProjectsWithTasks: showOnly,
            doNotLoadProjectList: doNotLoad,
            favoritesOnly: _favoritesOnly,
            query: _query,
          ),
        );
      },
      orElse: () {},
    );
  }

  /// In "Do not load project list" mode, projects are loaded only after the
  /// user explicitly submits the search (which may be empty).
  Future<void> submitSearch({bool showLoading = true}) async {
    await reload(showLoading: showLoading);
  }

  List<Project> _applyQuery(List<Project> allProjects, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allProjects;
    return allProjects
        .where((p) => p.title.toLowerCase().contains(q))
        .toList();
  }

  int? _projectNumericIdFromHref(String href) {
    try {
      final clean = href.split('?').first;
      final last = clean.split('/').where((e) => e.isNotEmpty).last;
      return int.tryParse(last);
    } catch (_) {
      return null;
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
        favoritesOnly: _favoritesOnly,
      );
    } catch (e) {
      emit(
        ProjectsListState.idle(
          allProjects: const [],
          projects: const [],
          query: _query,
          showOnlyProjectsWithTasks: _showOnlyProjectsWithTasks,
          doNotLoadProjectList: _doNotLoadProjectList,
          favoritesOnly: _favoritesOnly,
        ),
      );
      emitEffect(const ProjectsListEffect.error());
      return;
    }

    _hasLoadedProjectsOnce = true;

    var filteredProjects = projects;

    if (_showOnlyProjectsWithTasks) {
      try {
        final statuses = await _settingsRepository.workPackagesStatusFilter;
        final assigneeFilter = await _settingsRepository.assigneeFilter;

        // OpenProject collections are paginated. We iterate pages (offset based)
        // to reliably build the set of projects that have matching work packages,
        // while keeping the number of requests bounded.
        //
        // Docs: https://www.openproject.org/docs/api/collections/
        const pageSize = 200;
        const maxPages = 20; // safety cap to avoid excessively long requests

        final projectNumericIdsWithTasks = <int>{};
        final projectTitlesWithTasks = <String>{};

        int? offset = 1;
        var pagesFetched = 0;
        while (offset != null && pagesFetched < maxPages) {
          pagesFetched += 1;

          final page = await _workPackagesRepository.listPaged(
            projectId: null,
            pageSize: pageSize,
            offset: offset,
            statuses: statuses,
            user: assigneeFilter == 0 ? 'me' : null,
          );

          for (final wp in page.items) {
            final pid = _projectNumericIdFromHref(wp.projectHref);
            if (pid != null) {
              projectNumericIdsWithTasks.add(pid);
            }
            // Keep title as a last-resort fallback for instances where projects
            // are listed by identifier but the numeric id is not available.
            projectTitlesWithTasks.add(wp.projectTitle);
          }

          offset = page.nextOffset;
          if (page.count <= 0 || page.items.isEmpty) {
            break;
          }
        }

        filteredProjects = projects.where((p) {
          final nid = p.numericId;
          if (nid != null) {
            return projectNumericIdsWithTasks.contains(nid);
          }
          return projectTitlesWithTasks.contains(p.title);
        }).toList();
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
        favoritesOnly: _favoritesOnly,
      ),
    );
  }
}
