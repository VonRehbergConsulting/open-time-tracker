import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

import '/helpers/timer_storage.dart';

class TimerProvider with ChangeNotifier {
  // Properties

  TimerStorage storage;
  bool _isLoading = true;
  bool get isLoading {
    return _isLoading;
  }

  TimeEntry? _timeEntry;

  TimeEntry? get timeEntry {
    return _timeEntry;
  }

  void setTimeEntry(TimeEntry timeEntry) {
    _timeEntry = timeEntry;
    if (timeEntry.hours.inSeconds > 0) {
      _stopTime = DateTime.now();
      _startTime = _stopTime?.add(-timeEntry.hours);
    } else {
      _startTime = null;
      _stopTime = null;
    }
    _saveData();
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

  TimerProvider(this.storage) {
    _loadData();
  }

  void _loadData() async {
    _isLoading = true;
    notifyListeners();
    _timeEntry = await storage.getTimeEntry();
    _startTime = await storage.getStartTime();
    _stopTime = await storage.getStopTime();
    if (_timeEntry == null || _startTime == null) {
      reset();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Private methods
  void _saveData() {
    storage.setTimeEntry(_timeEntry);
    storage.setStartTime(_startTime);
    storage.setStopTime(_stopTime);
    notifyListeners();
  }

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
    _saveData();
  }

  void stopTimer() {
    if (_startTime != null && _stopTime == null) {
      _stopTime = DateTime.now();
    }
    _timeEntry?.hours = _stopTime!.difference(_startTime!);
    _saveData();
  }

  void reset() {
    _timeEntry = null;
    _startTime = null;
    _stopTime = null;
    _saveData();
  }
}
