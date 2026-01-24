import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';

import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_shimmer.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/widgets/total_time_list_item.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/widgets/date_navigator.dart';

import 'widgets/time_entry_list_item.dart';

class TimeEntriesListPage
    extends
        EffectBlocPage<
          TimeEntriesListBloc,
          TimeEntriesListState,
          TimeEntriesListEffect
        > {
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
    return SliverScreen(
      title: AppLocalizations.of(context).time_entries_list_title,
      onRefresh: context.read<TimeEntriesListBloc>().reload,
      actions: [
        IconButton(
          onPressed: () => AppRouter.routeToAnalytics(context),
          icon: const Icon(Icons.analytics_outlined),
        ),
        IconButton(
          onPressed: () => AppRouter.routeToProfile(context),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final createdEntry = await AppRouter.routeToProjectsList();
          if (createdEntry != null && context.mounted) {
            context.read<TimeEntriesListBloc>().addTimeEntry(createdEntry);
          }
        },
      ),
      scrollingEnabled: state.maybeWhen(
        loading: () => false,
        orElse: () => true,
      ),
      body: state.when(
        loading: () => const SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: ConfiguredShimmer(
                child: Column(
                  children: [
                    SizedBox(height: 8.0),
                    _DateNavigatorPlaceholder(),
                    _TotalTimePlaceholder(),
                    _ItemPlaceholder(),
                    _ItemPlaceholder(),
                    _ItemPlaceholder(),
                    _ItemPlaceholder(),
                  ],
                ),
              ),
            ),
          ],
        ),
        idle:
            (
              timeEntries,
              workingHours,
              totalDuration,
              selectedDate,
              isViewingToday,
            ) => SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: DateNavigator(
                    selectedDate: selectedDate,
                    onPreviousDay: () =>
                        context.read<TimeEntriesListBloc>().goToPreviousDay(),
                    onNextDay: () =>
                        context.read<TimeEntriesListBloc>().goToNextDay(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // Swipe right (positive velocity) = go to previous day
                      // Swipe left (negative velocity) = go to next day
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! > 0) {
                          // Swiped right - previous day (always allowed)
                          context.read<TimeEntriesListBloc>().goToPreviousDay();
                        } else if (details.primaryVelocity! < 0 &&
                            !isViewingToday) {
                          // Swiped left - next day (only if not viewing today)
                          context.read<TimeEntriesListBloc>().goToNextDay();
                        }
                      }
                    },
                    child: TotalTimeListItem(workingHours, totalDuration, (
                      value,
                    ) {
                      final duration = Duration(
                        hours: value.hour,
                        minutes: value.minute,
                      );
                      context.read<TimeEntriesListBloc>().updateWorkingHours(
                        duration,
                      );
                    }),
                  ),
                ),
                timeEntries.isEmpty
                    ? SliverScreenEmpty(
                        text: AppLocalizations.of(
                          context,
                        ).time_entries_list_empty,
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final timeEntry = timeEntries[index];
                          return TimeEntryListItem(
                            workPackageSubject: timeEntry.workPackageSubject,
                            projectTitle: timeEntry.projectTitle,
                            hours: timeEntry.hours,
                            comment: timeEntry.comment,
                            action: () async {
                              await context
                                  .read<TimeEntriesListBloc>()
                                  .setTimeEntry(timeEntry);
                              if (!isViewingToday) {
                                // For past dates, go directly to edit screen
                                if (context.mounted) {
                                  final updatedEntry =
                                      await AppRouter.routeToTimeEntrySummary(
                                        context,
                                      );
                                  // Optimistic update: immediately reflect changes in the UI
                                  if (updatedEntry != null && context.mounted) {
                                    context
                                        .read<TimeEntriesListBloc>()
                                        .updateTimeEntry(updatedEntry);
                                  }
                                }
                              }
                              // For today, the automatic navigation to timer page will happen
                            },
                            dismissAction: () async {
                              return await context
                                  .read<TimeEntriesListBloc>()
                                  .deleteTimeEntry(timeEntry.id!);
                            },
                          );
                        }, childCount: timeEntries.length),
                      ),
              ],
            ),
      ),
    );
  }
}

class _DateNavigatorPlaceholder extends StatelessWidget {
  const _DateNavigatorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DateNavigator(
      selectedDate: DateTime.now(),
      onPreviousDay: () {},
      onNextDay: () {},
    );
  }
}

class _TotalTimePlaceholder extends StatelessWidget {
  const _TotalTimePlaceholder();

  @override
  Widget build(BuildContext context) {
    return TotalTimeListItem(const Duration(), const Duration(), (_) {});
  }
}

class _ItemPlaceholder extends StatelessWidget {
  const _ItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const TimeEntryListItem(
      workPackageSubject: '',
      projectTitle: 'timeEntry.projectTitle',
      hours: Duration(),
      comment: '',
    );
  }
}
