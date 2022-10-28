import 'package:flutter/material.dart';

import '/models/time_entry.dart';

class TimerProvider with ChangeNotifier {
  // Properties

  TimeEntry? _timeEntry;

  TimeEntry? get timeEntry {
    return _timeEntry;
  }

  set timeEntry(TimeEntry? timeEntry) {
    reset();
    if (timeEntry == null) {
      return;
    }
    _timeEntry = timeEntry;
    _stopTime = DateTime.now();
    _startTime = _stopTime?.add(-timeEntry.hours);

    notifyListeners();
  }

  DateTime? _startTime;
  DateTime? _stopTime;

  Duration get timeSpent {
    if (_startTime == null) {
      return const Duration();
    }
    var greaterTime = _stopTime ?? DateTime.now();
    return greaterTime.difference(_startTime!);
  }

  bool get isActive {
    return _startTime != null && _stopTime == null;
  }

  bool get hasStarted {
    return _startTime != null;
  }

  // Init

  TimerProvider(this._timeEntry);

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
    _timeEntry?.hours = _stopTime!.difference(_startTime!);
    notifyListeners();
  }

  void reset() {
    _timeEntry = null;
    _startTime = null;
    _stopTime = null;
    notifyListeners();
  }
}
