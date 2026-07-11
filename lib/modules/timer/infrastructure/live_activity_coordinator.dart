import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';
import 'package:open_project_time_tracker/app/live_activity/infrastructure/default_live_activity_manager.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';

class LiveActivityCoordinator {
  final LiveActivityManager _liveActivityManager;

  DateTime? _sessionStart;
  String? _taskTitle;
  // Tracks whether we have already asked the platform layer to stop
  // any pre-existing activity. On cold-start our in-memory state is
  // null but the OS may still hold a stale live activity from a
  // previous run, so the first stop() must always reach the platform.
  bool _platformSynced = false;
  Future<void> _queue = Future.value();

  LiveActivityCoordinator(this._liveActivityManager);

  Map<String, dynamic> _activityModel({
    required DateTime sessionStart,
    required TimeEntry timeEntry,
    required String inProgressTag,
  }) {
    return LiveActivityModel(
      startTimestamp: (sessionStart.millisecondsSinceEpoch / 1000).round(),
      title: timeEntry.workPackageSubject,
      subtitle: timeEntry.projectTitle,
      tag: inProgressTag,
    ).toMap();
  }

  Future<void> _enqueue(Future<void> Function() operation) async {
    final next = _queue.then((_) => operation());
    _queue = next.catchError((_) {});
    await next;
  }

  Future<void> sync({
    required bool isActive,
    required Duration timeSpent,
    required TimeEntry? timeEntry,
    required String inProgressTag,
  }) async {
    if (timeEntry == null || !isActive) {
      await stop();
      return;
    }

    await _enqueue(() async {
      if (_sessionStart == null) {
        final sessionStart = DateTime.now().add(-timeSpent);
        try {
          await _liveActivityManager.stopLiveActivity();
          await _liveActivityManager.startLiveActivity(
            activityModel: _activityModel(
              sessionStart: sessionStart,
              timeEntry: timeEntry,
              inProgressTag: inProgressTag,
            ),
          );
          _sessionStart = sessionStart;
          _taskTitle = timeEntry.workPackageSubject;
          _platformSynced = true;
        } on LiveActivityPermissionException catch (e) {
          debugPrint('Live activity permission denied: ${e.message}');
        } catch (e) {
          debugPrint('Failed to start live activity: $e');
        }
        return;
      }

      if (_taskTitle != timeEntry.workPackageSubject) {
        try {
          await _liveActivityManager.updateLiveActivity(
            activityModel: _activityModel(
              sessionStart: _sessionStart!,
              timeEntry: timeEntry,
              inProgressTag: inProgressTag,
            ),
          );
          _taskTitle = timeEntry.workPackageSubject;
          _platformSynced = true;
        } on LiveActivityPermissionException catch (e) {
          debugPrint('Live activity permission denied: ${e.message}');
        } catch (e) {
          debugPrint('Failed to update live activity: $e');
        }
      }
    });
  }

  Future<void> start({
    required Duration timeSpent,
    required TimeEntry? timeEntry,
    required String inProgressTag,
  }) async {
    if (timeEntry == null) {
      return;
    }

    await _enqueue(() async {
      final sessionStart = DateTime.now().add(-timeSpent);
      try {
        if (_sessionStart == null) {
          await _liveActivityManager.stopLiveActivity();
          await _liveActivityManager.startLiveActivity(
            activityModel: _activityModel(
              sessionStart: sessionStart,
              timeEntry: timeEntry,
              inProgressTag: inProgressTag,
            ),
          );
        } else {
          await _liveActivityManager.updateLiveActivity(
            activityModel: _activityModel(
              sessionStart: sessionStart,
              timeEntry: timeEntry,
              inProgressTag: inProgressTag,
            ),
          );
        }
        _sessionStart = sessionStart;
        _taskTitle = timeEntry.workPackageSubject;
        _platformSynced = true;
      } on LiveActivityPermissionException catch (e) {
        debugPrint('Live activity permission denied: ${e.message}');
      } catch (e) {
        debugPrint('Failed to start live activity: $e');
      }
    });
  }

  Future<void> add({
    required Duration duration,
    required TimeEntry? timeEntry,
    required String inProgressTag,
  }) async {
    if (_sessionStart == null || timeEntry == null) {
      return;
    }

    await _enqueue(() async {
      final currentStart = _sessionStart;
      if (currentStart == null) {
        return;
      }
      final adjustedStart = currentStart.add(-duration);
      try {
        await _liveActivityManager.updateLiveActivity(
          activityModel: _activityModel(
            sessionStart: adjustedStart,
            timeEntry: timeEntry,
            inProgressTag: inProgressTag,
          ),
        );
        _sessionStart = adjustedStart;
      } on LiveActivityPermissionException catch (e) {
        debugPrint('Live activity permission denied: ${e.message}');
      } catch (e) {
        debugPrint('Failed to update live activity: $e');
      }
    });
  }

  Future<void> stop() async {
    if (_platformSynced && _sessionStart == null && _taskTitle == null) {
      return;
    }
    await _enqueue(() async {
      try {
        await _liveActivityManager.stopLiveActivity();
      } catch (e) {
        debugPrint('Failed to stop live activity: $e');
      } finally {
        _sessionStart = null;
        _taskTitle = null;
        _platformSynced = true;
      }
    });
  }
}
