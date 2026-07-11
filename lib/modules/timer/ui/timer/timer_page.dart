import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide FilledButton;
import 'package:flutter/services.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/live_activity/infrastructure/notification_permission_helper.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_bloc.dart';

import 'package:open_project_time_tracker/l10n/app_localizations.dart';

import '../../../../app/ui/widgets/configured_outlined_button.dart';

// ignore: must_be_immutable
class TimerPage extends EffectBlocPage<TimerBloc, TimerState, TimerEffect> {
  const TimerPage({super.key});

  void _minimize(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    AppRouter.routeToTimeEntriesListTemporary(context);
  }

  void _showCloseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: ((_) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).generic_warning),
        content: Text(AppLocalizations.of(context).timer_warning),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).generic_no),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await context.read<TimerBloc>().reset();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              _minimize(context);
            },
            child: Text(AppLocalizations.of(context).generic_yes),
          ),
        ],
      )),
    );
  }

  @override
  void onEffect(BuildContext context, TimerEffect effect) {
    effect.when(
      finish: () {
        // The timer just stopped and we want to save its entry.
        // Opt out of the active-timer redirect: even if `isActive`
        // still momentarily reports true (race between stopTime
        // being written and this effect firing), the correct next
        // step is the summary page, not another push of the timer.
        AppRouter.routeToTimeEntrySummary(
          context,
          skipActiveTimerRedirect: true,
        ).then((savedEntry) {
          if (savedEntry != null && context.mounted) {
            AppRouter.routeToTimeEntriesListTemporary(context);
          }
        });
      },
      error: () {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).generic_error),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  void onCreate(BuildContext context, TimerBloc bloc) {
    super.onCreate(context, bloc);
    bloc.updateState();

    // Proactively request notification permission on first launch after update
    // This provides better UX by explaining why the permission is needed
    _startNotificationPermissionFlow(context);
  }

  void _startNotificationPermissionFlow(BuildContext context) {
    unawaited(() async {
      try {
        await _requestNotificationPermissionIfNeeded(context);
      } catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'timer_page',
            context: ErrorDescription(
              'while requesting notification permission from TimerPage.onCreate',
            ),
          ),
        );
      }
    }());
  }

  Future<void> _requestNotificationPermissionIfNeeded(
    BuildContext context,
  ) async {
    // Only show permission dialog if this is the first time
    if (await NotificationPermissionHelper.shouldRequestPermission()) {
      // Wait a bit to let the page render first
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        await NotificationPermissionHelper.requestPermissionWithDialog(context);
      }
    }
  }

  @override
  Widget buildState(BuildContext context, TimerState state) {
    var leftButtonTitle = AppLocalizations.of(context).timer_start;
    if (state.isActive) {
      leftButtonTitle = AppLocalizations.of(context).timer_pause;
    } else if (state.hasStarted) {
      leftButtonTitle = AppLocalizations.of(context).timer_resume;
    }

    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.39;
    final addButtonWidth = deviceSize.width * 0.23;

    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _minimize(context),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          IconButton(
            onPressed: () => _showCloseDialog(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 11),
            Text(
              state.timeSpent.longWatch(),
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                state.title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Text(
              state.subtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(flex: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: addButtonWidth,
                  child: ConfiguredOutlinedButton(
                    text: AppLocalizations.of(context).timer_add_5_min,
                    textStyle: const TextStyle(fontSize: 14),
                    onPressed: () => context.read<TimerBloc>().add(
                      const Duration(minutes: 5),
                    ),
                  ),
                ),
                SizedBox(
                  width: addButtonWidth,
                  child: ConfiguredOutlinedButton(
                    text: AppLocalizations.of(context).timer_add_15_min,
                    textStyle: const TextStyle(fontSize: 14),
                    onPressed: () => context.read<TimerBloc>().add(
                      const Duration(minutes: 15),
                    ),
                  ),
                ),
                SizedBox(
                  width: addButtonWidth,
                  child: ConfiguredOutlinedButton(
                    text: AppLocalizations.of(context).timer_add_30_min,
                    textStyle: const TextStyle(fontSize: 14),
                    onPressed: () => context.read<TimerBloc>().add(
                      const Duration(minutes: 30),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: FilledButton(
                    onPressed: (state.isActive
                        ? context.read<TimerBloc>().stop
                        : context.read<TimerBloc>().start),
                    text: leftButtonTitle,
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: FilledButton(
                    onPressed: (state.hasStarted
                        ? context.read<TimerBloc>().finish
                        : null),
                    text: AppLocalizations.of(context).timer_finish,
                  ),
                ),
              ],
            ),
            const Spacer(flex: 14),
          ],
        ),
      ),
    );
  }
}
