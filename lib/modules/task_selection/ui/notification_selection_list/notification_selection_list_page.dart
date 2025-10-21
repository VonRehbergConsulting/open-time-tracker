import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/notification_selection_list/notification_selection_list_bloc.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/widgets/time_entry_list_item.dart';

import '../../../../app/ui/bloc/bloc_page.dart';
import '../../../../app/ui/widgets/activity_indicator.dart';
import '../work_packages_list/widgets/work_package_list_item.dart';

class NotificationSelectionListPage
    extends
        EffectBlocPage<
          NotificationSelectionListBloc,
          NotificationSelectionListState,
          NotificationSelectionListEffect
        > {
  const NotificationSelectionListPage({super.key});

  @override
  void onCreate(BuildContext context, NotificationSelectionListBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  void onEffect(BuildContext context, NotificationSelectionListEffect effect) {
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
  Widget buildState(
    BuildContext context,
    NotificationSelectionListState state,
  ) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: context.read<NotificationSelectionListBloc>().reload,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: CustomScrollView(
            physics: state.whenOrNull(
              loading: () => const NeverScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                title: Text(
                  AppLocalizations.of(
                    context,
                  ).notification_selection_list__title,
                ),
              ),
              ...state.when<List<Widget>>(
                loading: () => [
                  const SliverFillRemaining(
                    child: Center(child: ActivityIndicator()),
                  ),
                ],
                idle: (timeEntries, workPackages) => [
                  if (timeEntries.isNotEmpty)
                    _sectionHeader(
                      AppLocalizations.of(
                        context,
                      ).notification_selection_list__time_entries_header,
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final timeEntry = timeEntries[index];
                      return TimeEntryListItem(
                        workPackageSubject: timeEntry.workPackageSubject,
                        projectTitle: timeEntry.projectTitle,
                        hours: timeEntry.hours,
                        comment: timeEntry.comment,
                        action: () {
                          context
                              .read<NotificationSelectionListBloc>()
                              .setTimeEntry(timeEntry);
                        },
                        dismissAction: () async {
                          return false;
                        },
                      );
                    }, childCount: timeEntries.length),
                  ),
                  if (workPackages.isNotEmpty)
                    _sectionHeader(
                      AppLocalizations.of(
                        context,
                      ).notification_selection_list__work_packages_header,
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final workPackage = workPackages[index];
                      return WorkPackageListItem(
                        subject: workPackage.subject,
                        projectTitle: workPackage.projectTitle,
                        status: workPackage.status,
                        priority: workPackage.priority,
                        action: () {
                          context
                              .read<NotificationSelectionListBloc>()
                              .setTimeEntryFromWorkPackage(workPackage);
                        },
                      );
                    }, childCount: workPackages.length),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 8.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ),
    );
  }
}
