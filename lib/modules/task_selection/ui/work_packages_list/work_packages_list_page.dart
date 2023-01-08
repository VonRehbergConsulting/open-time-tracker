import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_bloc.dart';

import 'widgets/work_package_list_item.dart';

class WorkPackagesListPage
    extends BlocPage<WorkPackagesListBloc, WorkPackagesListState> {
  @override
  void onCreate(BuildContext context, WorkPackagesListBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  Widget buildState(BuildContext context, WorkPackagesListState state) {
    final Widget body = state.when(
      loading: () => const Center(child: ActivityIndicator()),
      idle: (workPackages) => RefreshIndicator(
        onRefresh: () async {
          context.read<WorkPackagesListBloc>().reload();
        },
        child: ListView.builder(
          itemCount: workPackages.length,
          itemBuilder: ((_, index) {
            final workPackage = workPackages[index];
            return WorkPackageListItem(
                subject: workPackage.subject,
                projectTitle: workPackage.projectTitle,
                status: workPackage.status,
                priority: workPackage.priority,
                action: () async {
                  // TODO: switch to effects
                  await context
                      .read<WorkPackagesListBloc>()
                      .setTimeEntry(workPackage);
                  AppRouter.routeToTimer(context);
                });
          }),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: body,
      ),
    );
  }
}
