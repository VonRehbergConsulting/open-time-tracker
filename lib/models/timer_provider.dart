import 'package:flutter/material.dart';

import '/models/time_entry.dart';

class TimerProvider with ChangeNotifier {
  // Properties

  TimeEntry? timeEntry;

  DateTime? _startTime;
  DateTime? _stopTime;

  Duration get timeSpent {
    if (_startTime == null) {
      return const Duration();
    }
    var greaterTime = _stopTime ?? DateTime.now();
    return greaterTime.difference(_startTime!);
  }

  // Init

  TimerProvider({this.timeEntry});

  // Public methods

  void startTimer() {
    if (_startTime == null) {
      _stopTime = null;
      _startTime = DateTime.now();
    } else if (_stopTime != null) {
      final duration = DateTime.now().difference(_stopTime!);
      _startTime = _startTime?.add(duration);
      _stopTime = null;
    }
    notifyListeners();
  }

  void stopTimer() {
    if (_startTime != null && _stopTime == null) {
      _stopTime = DateTime.now();
    }
    notifyListeners();
  }

  void reset() {
    timeEntry = null;
    _startTime = null;
    _stopTime = null;
    notifyListeners();
  }
}
