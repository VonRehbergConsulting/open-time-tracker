import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

part 'time_entry_summary_bloc.freezed.dart';

@freezed
class TimeEntrySummaryState with _$TimeEntrySummaryState {
  const factory TimeEntrySummaryState.loading() = _Loading;
  const factory TimeEntrySummaryState.idle({
    required String title,
    required String projectTitle,
    required Duration timeSpent,
    required String? comment,
    required List<String> commentSuggestions,
  }) = _Idle;
}

@freezed
class TimeEntrySummaryEffect with _$TimeEntrySummaryEffect {
  const factory TimeEntrySummaryEffect.complete() = _Complete;
  const factory TimeEntrySummaryEffect.error() = _Error;
}

class TimeEntrySummaryBloc
    extends EffectCubit<TimeEntrySummaryState, TimeEntrySummaryEffect> {
  TimeEntriesRepository _timeEntriesRepository;
  UserDataRepository _userDataRepository;
  TimerRepository _timerRepository;

  late TimeEntry timeEntry;
  List<String> _commentSuggestions = [];

  TimeEntrySummaryBloc(
    this._timeEntriesRepository,
    this._userDataRepository,
    this._timerRepository,
  ) : super(TimeEntrySummaryState.loading()) {
    _init();
  }

  Future<void> _emitIdleState() async {
    emit(
      TimeEntrySummaryState.idle(
        title: timeEntry.workPackageSubject,
        projectTitle: timeEntry.projectTitle,
        timeSpent: timeEntry.hours,
        comment: timeEntry.comment,
        commentSuggestions: _commentSuggestions,
      ),
    );
  }

  Future<void> _init() async {
    final timeEntry = await _timerRepository.timeEntry;
    if (timeEntry != null) {
      final minutes = max(timeEntry.hours.inMinutes, 1);
      timeEntry.hours = Duration(minutes: minutes);
      this.timeEntry = timeEntry;
      try {
        final workPackageIdString = timeEntry.workPackageHref.split('/').last;
        final workPackageId = int.tryParse(workPackageIdString);
        final timeEntries =
            await _timeEntriesRepository.list(workPackageId: workPackageId);
        var comments = timeEntries.map((e) => e.comment ?? '').toSet().toList();
        comments.remove('');
        _commentSuggestions = comments;
      } catch (e) {}

      _emitIdleState();
    } else {
      emitEffect(TimeEntrySummaryEffect.error());
    }
  }

  Future<void> updateTimeSpent(Duration timeSpent) async {
    timeEntry.hours = timeSpent;
    _emitIdleState();
  }

  Future<void> updateComment(String comment) async {
    timeEntry.comment = comment;
  }

  Future<void> submit() async {
    emit(TimeEntrySummaryState.loading());
    try {
      final userId = await _userDataRepository.userID;
      if (userId == null) {
        throw Exception('User ID is null');
      }
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
      emitEffect(TimeEntrySummaryEffect.complete());
    } catch (e) {
      _emitIdleState();
      emitEffect(TimeEntrySummaryEffect.error());
    }
  }
}
