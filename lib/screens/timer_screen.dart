import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/timer_provider.dart';
import '/services/DurationFormatter.dart';

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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        leading: IconButton(
          onPressed: () {
            Provider.of<TimerProvider>(context, listen: false).reset();
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Consumer<TimerProvider>(
              builder: (context, timerProvider, child) => Text(
                DurationFormatter.longWatch(timerProvider.timeSpent),
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (() => _startTimer()),
                child: const Text('Start'),
              ),
              ElevatedButton(
                onPressed: (() => _stopTimer()),
                child: const Text('Stop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
