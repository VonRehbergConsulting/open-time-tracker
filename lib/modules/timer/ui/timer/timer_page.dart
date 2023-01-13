import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_bloc.dart';

// ignore: must_be_immutable
class TimerPage extends EffectBlocPage<TimerBloc, TimerState, TimerEffect> {
  Timer? timer;

  void _showCloseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: ((_) => CupertinoAlertDialog(
            title: const Text('Warning'),
            content:
                const Text('Your current changes will not be saved. Continue?'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('No'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  await context.read<TimerBloc>().reset();
                  AppRouter.routeToTimeEntriesListTemporary(context);
                },
                child: Text('Yes'),
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
    var leftButtonTitle = 'Start';
    if (state.isActive) {
      leftButtonTitle = 'Pause';
    } else if (state.hasStarted) {
      leftButtonTitle = 'Resume';
    }

    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.35;

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
      backgroundColor: Colors.white,
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
                  width: buttonWidth,
                  child: CupertinoButton.filled(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    onPressed: (state.isActive
                        ? context.read<TimerBloc>().stop
                        : context.read<TimerBloc>().start),
                    child: Text(leftButtonTitle),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: CupertinoButton.filled(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    onPressed: (state.hasStarted
                        ? context.read<TimerBloc>().finish
                        : null),
                    child: const Text('Finish'),
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
