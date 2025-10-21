import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';

import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_shimmer.dart';
import 'package:open_project_time_tracker/app/ui/widgets/screens/scrollable_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/widgets/total_time_list_item.dart';

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
    bloc.reload().then((_) {
      bloc.checkAnalyticsConsent();
    });
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
      requestAnalyticsConsent: (setConsentHandler, openPrivacyPolicyHandler) {
        Future.delayed(const Duration(milliseconds: 2000)).then((_) {
          showCupertinoDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(
                  AppLocalizations.of(context).analytics_consent_request__title,
                ),
                content: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: AppLocalizations.of(
                      context,
                    ).analytics_consent_request__text,
                    style: const TextStyle(fontSize: 14.0, color: Colors.black),
                    children: [
                      TextSpan(
                        text:
                            '\n${AppLocalizations.of(context).analytics_consent_request__privacy_policy}',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = openPrivacyPolicyHandler,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),

                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setConsentHandler(false);
                      Navigator.of(context).pop(false);
                    },
                    child: Text(AppLocalizations.of(context).generic_decline),
                  ),
                  TextButton(
                    onPressed: () {
                      setConsentHandler(true);
                      Navigator.of(context).pop(true);
                    },
                    child: Text(AppLocalizations.of(context).generic_accept),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget buildState(BuildContext context, TimeEntriesListState state) {
    return SliverScreen(
      title: AppLocalizations.of(context).time_entries_list_title,
      onRefresh: context.read<TimeEntriesListBloc>().reload,
      leading: IconButton(
        onPressed: () {
          context.read<TimeEntriesListBloc>().unauthorize();
        },
        icon: const Icon(Icons.logout),
      ),
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => AppRouter.routeToProjectsList(),
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
        idle: (timeEntries, workingHours, totalDuration) => SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: TotalTimeListItem(workingHours, totalDuration, (value) {
                final duration = Duration(
                  hours: value.hour,
                  minutes: value.minute,
                );
                context.read<TimeEntriesListBloc>().updateWorkingHours(
                  duration,
                );
              }),
            ),
            timeEntries.isEmpty
                ? SliverScreenEmpty(
                    text: AppLocalizations.of(context).time_entries_list_empty,
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final timeEntry = timeEntries[index];
                      return TimeEntryListItem(
                        workPackageSubject: timeEntry.workPackageSubject,
                        projectTitle: timeEntry.projectTitle,
                        hours: timeEntry.hours,
                        comment: timeEntry.comment,
                        action: () {
                          context.read<TimeEntriesListBloc>().setTimeEntry(
                            timeEntry,
                          );
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
