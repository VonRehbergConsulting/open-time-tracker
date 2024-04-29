import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/app/ui/widgets/segmented_control.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_bloc.dart';

import 'widgets/work_package_list_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkPackagesListPage extends EffectBlocPage<WorkPackagesListBloc,
    WorkPackagesListState, WorkPackagesListEffect> {
  const WorkPackagesListPage({super.key});

  @override
  void onCreate(BuildContext context, WorkPackagesListBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  void onEffect(BuildContext context, WorkPackagesListEffect effect) {
    effect.when(
      complete: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
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
  Widget buildState(BuildContext context, WorkPackagesListState state) {
    return SliverScreen(
      title: AppLocalizations.of(context).work_packages_list_title,
      actions: [
        IconButton(
          onPressed: () => AppRouter.routeToWorkPackagesFilter(
            comppletion: () {
              context.read<WorkPackagesListBloc>().reload(showLoading: true);
            },
          ),
          icon: const Icon(Icons.filter_alt_rounded),
        )
      ],
      scrollingEnabled:
          state.maybeWhen(loading: (_) => false, orElse: () => true),
      onRefresh: () async {
        await context.read<WorkPackagesListBloc>().reload();
      },
      body: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SegmentedControl(
              groupValue: state.dataSource,
              children: {
                WorkPackagesListDataSource.user:
                    AppLocalizations.of(context).work_packages_list_tab_user,
                WorkPackagesListDataSource.groups:
                    AppLocalizations.of(context).work_packages_list_tab_groups,
              },
              onValueChanged: (dataSource) async {
                await context.read<WorkPackagesListBloc>().reload(
                      showLoading: true,
                      newDataSource: dataSource,
                    );
              },
            ),
          ),
        ),
        ...state.when(
          loading: (_) => [
            const SliverScreenLoading(),
          ],
          idle: (
            workPackages,
            dataSource,
          ) =>
              [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ...workPackages.entries.map(
                    (projectWorkPackages) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            projectWorkPackages.key,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        ...projectWorkPackages.value.map(
                          (workPackage) => WorkPackageListItem(
                              subject: workPackage.subject,
                              projectTitle: workPackage.projectTitle,
                              status: workPackage.status,
                              priority: workPackage.priority,
                              action: () {
                                context
                                    .read<WorkPackagesListBloc>()
                                    .setTimeEntry(workPackage);
                              }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
