import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/services/app_router.dart';
import 'package:provider/provider.dart';

import '/models/timer_provider.dart';
import '/services/duration_formatter.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? timer;

  void _startTimer() {
    Provider.of<TimerProvider>(context, listen: false).startTimer();
    timer ??= Timer.periodic(
      const Duration(seconds: 1),
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
  }

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
      leftButtonTitle = 'Pause';
    } else if (timerProvider.hasStarted) {
      leftButtonTitle = 'Resume';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        leading: IconButton(
          onPressed: () {
            timerProvider.reset();
            AppRouter.routeToTimeEntriesList(context, widget);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              DurationFormatter.longWatch(timerProvider.timeSpent),
              style: const TextStyle(
                fontSize: 50,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (timerProvider.isActive
                    ? () => _stopTimer()
                    : () => _startTimer()),
                child: Text(leftButtonTitle),
              ),
              ElevatedButton(
                onPressed: (timerProvider.hasStarted ? () => _finish() : null),
                child: const Text('Finish'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
