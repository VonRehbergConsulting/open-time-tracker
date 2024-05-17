import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_bloc.dart';

import '../../domain/work_packages_repository.dart';
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
          state.maybeWhen(loading: () => false, orElse: () => true),
      onRefresh: () async {
        await context.read<WorkPackagesListBloc>().reload();
      },
      body: state.when(
        loading: () => const SliverScreenLoading(),
        idle: (
          workPackages,
        ) =>
            SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(
                height: 8.0,
              ),
              ...workPackages.entries.map(
                (projectWorkPackages) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          projectWorkPackages.key,
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    ...projectWorkPackages.value.map(
                      (workPackage) => WorkPackageListItem(
                          subject: workPackage.subject,
                          projectTitle: workPackage.projectTitle,
                          status: workPackage.status,
                          priority: workPackage.priority,
                          commentTrailing: workPackage.assignee.type ==
                                  WorkPackageAssigneeType.group
                              ? _GroupName(
                                  text: workPackage.assignee.title,
                                )
                              : null,
                          action: () {
                            context
                                .read<WorkPackagesListBloc>()
                                .setTimeEntry(workPackage);
                          }),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupName extends StatelessWidget {
  final String text;

  const _GroupName({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          width: 6.0,
        ),
        Icon(
          Icons.people,
          color: theme.primaryColor,
          size: 18,
        ),
      ],
    );
  }
}
