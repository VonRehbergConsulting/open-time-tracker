import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_service.dart';

import '../../authorization/domain/user_data_repository.dart';
import '../../task_selection/domain/time_entries_repository.dart';
import '../domain/timer_repository.dart';

class ApiTimerService implements TimerService {
  final TimeEntriesRepository _timeEntriesRepository;
  final UserDataRepository _userDataRepository;
  final TimerRepository _timerRepository;

  ApiTimerService(
    this._timeEntriesRepository,
    this._userDataRepository,
    this._timerRepository,
  );
  @override
  Future<void> submit({TimeEntry? timeEntry}) async {
    if (timeEntry == null) {
      final entry = await _timerRepository.timeEntry;
      final timeSpent = await _timerRepository.timeSpent;
      entry?.hours = Duration(minutes: timeSpent.inSeconds ~/ 60);
      if (entry == null) {
        throw ErrorDescription('Time entry is null');
      }
      timeEntry = entry;
    }
    final userId = await _userDataRepository.userId();
    if (timeEntry.id == null) {
      await _timeEntriesRepository.create(
        timeEntry: timeEntry,
        userId: userId,
      );
    } else {
      await _timeEntriesRepository.update(
        timeEntry: timeEntry,
      );
    }
    await _timerRepository.reset();
  }
}
