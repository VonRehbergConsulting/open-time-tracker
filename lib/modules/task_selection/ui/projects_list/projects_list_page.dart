import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_shimmer.dart';
import 'package:open_project_time_tracker/app/ui/widgets/list_item.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/projects_list/projects_list_bloc.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

class ProjectsListPage
    extends
        EffectBlocPage<
          ProjectsListBloc,
          ProjectsListState,
          ProjectsListEffect
        > {
  const ProjectsListPage({super.key});

  @override
  void onCreate(BuildContext context, ProjectsListBloc bloc) {
    super.onCreate(context, bloc);
    bloc.onPageOpened();
  }

  @override
  void onEffect(BuildContext context, ProjectsListEffect effect) {
    effect.when(
      error: () {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context).generic_error),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  @override
  Widget buildState(BuildContext context, ProjectsListState state) {
    return SliverScreen(
      title: AppLocalizations.of(context).projects_list__title,
      onRefresh: () => context.read<ProjectsListBloc>().reload(showLoading: true),
      body: state.when(
        loading: () => const SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: ConfiguredShimmer(
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ],
        ),
        notLoaded: (showOnlyProjectsWithTasks, doNotLoadProjectList, query) =>
            SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  AppLocalizations.of(context).projects_list__not_loaded_hint,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12.0)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton.icon(
                  onPressed: () => context
                      .read<ProjectsListBloc>()
                      .reload(showLoading: true),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(
                    AppLocalizations.of(context).projects_list__load_button,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          ],
        ),
        idle:
            (
          allProjects,
          projects,
          query,
          showOnlyProjectsWithTasks,
          doNotLoadProjectList,
        ) => SliverMainAxisGroup(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .projects_list__search_hint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: query,
                  onChanged: context.read<ProjectsListBloc>().setQuery,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: projects.length,
                (context, index) => ListItem(
                  title: projects[index].title,
                  comment: projects[index].updatedAt != null
                      ? '${AppLocalizations.of(context).projects_list__updated_at} ${DateFormat('dd.MM.yyyy').format(projects[index].updatedAt!)}'
                      : null,
                  action: () async {
                    final createdEntry =
                        await AppRouter.routeToWorkPackagesList(
                          project: projects[index],
                        );
                    if (createdEntry != null && context.mounted) {
                      Navigator.of(context).pop(createdEntry);
                    }
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          ],
        ),
      ),
    );
  }
}
