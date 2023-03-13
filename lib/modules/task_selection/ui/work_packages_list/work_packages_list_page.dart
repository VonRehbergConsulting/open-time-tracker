import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_bloc.dart';

import 'widgets/work_package_list_item.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkPackagesListPage extends EffectBlocPage<WorkPackagesListBloc,
    WorkPackagesListState, WorkPackagesListEffect> {
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
    final Widget body = state.when(
      loading: () => const Center(child: ActivityIndicator()),
      idle: (workPackages) => RefreshIndicator(
        onRefresh: () async {
          context.read<WorkPackagesListBloc>().reload();
        },
        child: workPackages.length == 0
            ? Center(
                child: Text(
                  AppLocalizations.of(context).work_package_list_empty,
                ),
              )
            : ListView.builder(
                itemCount: workPackages.length,
                itemBuilder: ((_, index) {
                  final workPackage = workPackages[index];
                  return WorkPackageListItem(
                      subject: workPackage.subject,
                      projectTitle: workPackage.projectTitle,
                      status: workPackage.status,
                      priority: workPackage.priority,
                      action: () {
                        context
                            .read<WorkPackagesListBloc>()
                            .setTimeEntry(workPackage);
                      });
                }),
              ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).work_packages_list_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: body,
      ),
    );
  }
}
