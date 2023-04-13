import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../app/ui/widgets/configured_outlined_button.dart';

// ignore: must_be_immutable
class TimerPage extends EffectBlocPage<TimerBloc, TimerState, TimerEffect> {
  Timer? timer;

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
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context).generic_yes),
              ),
            ],
          )),
    );
  }

  @override
  void onEffect(BuildContext context, TimerEffect effect) {
    effect.when(finish: () => AppRouter.routeToTimeEntrySummary(context));
  }

  @override
  void onCreate(BuildContext context, TimerBloc bloc) {
    super.onCreate(context, bloc);
    bloc.updateState();
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

    if (state.isActive) {
      timer ??= Timer.periodic(
        const Duration(milliseconds: 500),
        (timer) {
          context.read<TimerBloc>().updateState();
        },
      );
    } else {
      timer?.cancel();
      timer = null;
    }

    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () => _showCloseDialog(context),
        icon: const Icon(Icons.close),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
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
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ]),
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
                    textStyle: TextStyle(fontSize: 14),
                    onPressed: () =>
                        context.read<TimerBloc>().add(Duration(minutes: 5)),
                  ),
                ),
                SizedBox(
                  width: addButtonWidth,
                  child: ConfiguredOutlinedButton(
                    text: AppLocalizations.of(context).timer_add_15_min,
                    textStyle: TextStyle(fontSize: 14),
                    onPressed: () =>
                        context.read<TimerBloc>().add(Duration(minutes: 15)),
                  ),
                ),
                SizedBox(
                  width: addButtonWidth,
                  child: ConfiguredOutlinedButton(
                    text: AppLocalizations.of(context).timer_add_30_min,
                    textStyle: TextStyle(fontSize: 14),
                    onPressed: () =>
                        context.read<TimerBloc>().add(Duration(minutes: 30)),
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
