import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/helpers/app_router.dart';
import '/models/timer_provider.dart';
import '/extensions/duration.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? timer;

  void _startTimer() {
    Provider.of<TimerProvider>(context, listen: false).startTimer();
    _createUpdateTimer();
  }

  void _createUpdateTimer() {
    timer ??= Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        setState(() {});
      },
    );
  }

  void _stopTimer() {
    Provider.of<TimerProvider>(context, listen: false).stopTimer();
    timer?.cancel();
    timer = null;
  }

  void _finish() {
    _stopTimer();
    final timeEntry =
        Provider.of<TimerProvider>(context, listen: false).timeEntry;
    if (timeEntry != null) {
      if (timeEntry.hours.inMinutes < 1) {
        timeEntry.hours = const Duration(minutes: 1);
      }
      AppRouter.routeToTimeEntrySummary(context, timeEntry);
    }
  }

  void _showCloseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: ((context) => CupertinoAlertDialog(
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
                onPressed: () {
                  final timerProvider =
                      Provider.of<TimerProvider>(context, listen: false);
                  // AppRouter.routeToTimeEntriesList(
                  // context, widget, timerProvider.reset);
                },
                child: Text('Yes'),
              ),
            ],
          )),
    );
  }

  // Lifecycle

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    var leftButtonTitle = 'Start';
    if (timerProvider.isActive) {
      _createUpdateTimer();
      leftButtonTitle = 'Pause';
    } else if (timerProvider.hasStarted) {
      leftButtonTitle = 'Resume';
    }

    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.35;

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
              timerProvider.timeSpent.longWatch(),
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
                timerProvider.timeEntry?.workPackageSubject ?? '',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Text(
              timerProvider.timeEntry?.projectTitle ?? '',
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
                    onPressed: (timerProvider.isActive
                        ? () => _stopTimer()
                        : () => _startTimer()),
                    child: Text(leftButtonTitle),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: CupertinoButton.filled(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    onPressed:
                        (timerProvider.hasStarted ? () => _finish() : null),
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
