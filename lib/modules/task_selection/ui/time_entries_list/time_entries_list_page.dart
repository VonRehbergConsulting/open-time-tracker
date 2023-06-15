import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';

import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/widgets/total_time_list_item.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';

import 'widgets/time_entry_list_item.dart';

class TimeEntriesListPage extends EffectBlocPage<TimeEntriesListBloc,
    TimeEntriesListState, TimeEntriesListEffect> {
  const TimeEntriesListPage({super.key});

  @override
  void onCreate(BuildContext context, TimeEntriesListBloc bloc) {
    super.onCreate(context, bloc);
    bloc.reload();
  }

  @override
  void onEffect(BuildContext context, TimeEntriesListEffect effect) {
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
  Widget buildState(BuildContext context, TimeEntriesListState state) {
    final Widget body = RefreshIndicator(
      onRefresh: context.read<TimeEntriesListBloc>().reload,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: CustomScrollView(
          physics: state.whenOrNull(
            loading: () => const NeverScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              title: Text(AppLocalizations.of(context).time_entries_list_title),
              leading: IconButton(
                  onPressed: () {
                    context.read<TimeEntriesListBloc>().unauthorize();
                  },
                  icon: const Icon(Icons.logout)),
              actions: [
                IconButton(
                  onPressed: () => AppRouter.routeToCalendar(context),
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                IconButton(
                  onPressed: () => AppRouter.routeToAnalytics(context),
                  icon: const Icon(Icons.bar_chart),
                ),
              ],
            ),
            ...state.when<List<Widget>>(
              loading: () => [
                const SliverFillRemaining(
                  child: Center(
                    child: ActivityIndicator(),
                  ),
                ),
              ],
              idle: (timeEntries, workingHours, totalDuration) => [
                SliverToBoxAdapter(
                  child: TotalTimeListItem(
                    workingHours,
                    totalDuration,
                    (value) {
                      final duration = Duration(
                        hours: value.hour,
                        minutes: value.minute,
                      );
                      context
                          .read<TimeEntriesListBloc>()
                          .updateWorkingHours(duration);
                    },
                  ),
                ),
                timeEntries.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)
                                .time_entries_list_empty,
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final timeEntry = timeEntries[index];
                            return TimeEntryListItem(
                              workPackageSubject: timeEntry.workPackageSubject,
                              projectTitle: timeEntry.projectTitle,
                              hours: timeEntry.hours,
                              comment: timeEntry.comment,
                              action: () {
                                context
                                    .read<TimeEntriesListBloc>()
                                    .setTimeEntry(timeEntry);
                              },
                              dismissAction: () async {
                                return await context
                                    .read<TimeEntriesListBloc>()
                                    .deleteTimeEntry(timeEntry.id!);
                              },
                            );
                          },
                          childCount: timeEntries.length,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => AppRouter.routeToWorkPackagesList(),
      ),
    );
  }
}
