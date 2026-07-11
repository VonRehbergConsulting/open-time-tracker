import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_service.dart';

part 'time_entry_summary_bloc.freezed.dart';

@freezed
class TimeEntrySummaryState with _$TimeEntrySummaryState {
  const factory TimeEntrySummaryState.loading() = _Loading;
  const factory TimeEntrySummaryState.idle({
    required String title,
    required String projectTitle,
    required Duration timeSpent,
    required String? comment,
    required List<String>? commentSuggestions,
  }) = _Idle;
}

@freezed
class TimeEntrySummaryEffect with _$TimeEntrySummaryEffect {
  const factory TimeEntrySummaryEffect.complete({
    required TimeEntry timeEntry,
  }) = _Complete;
  const factory TimeEntrySummaryEffect.error() = _Error;
}

class TimeEntrySummaryBloc
    extends EffectCubit<TimeEntrySummaryState, TimeEntrySummaryEffect> {
  final TimeEntriesRepository _timeEntriesRepository;
  final TimerRepository _timerRepository;
  final TimerService _timerService;

  late TimeEntry timeEntry;
  List<String>? _commentSuggestions;
  bool _initStarted = false;

  TimeEntrySummaryBloc(
    this._timeEntriesRepository,
    this._timerRepository,
    this._timerService,
  ) : super(const TimeEntrySummaryState.loading());

  /// Called by the page (via [EffectBlocPage.onCreate]) with an optional
  /// draft entry. When [draft] is null the bloc loads the active entry from
  /// the timer repository (edit-current-timer flow). When [draft] is
  /// provided (edit-past-entry flow) the timer repository is not touched,
  /// so the running timer is preserved.
  void init({TimeEntry? draft}) {
    if (_initStarted) return;
    _initStarted = true;
    unawaited(_init(draft));
  }

  Future<void> _emitIdleState() async {
    if (isClosed) return;
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

  Future<void> _init(TimeEntry? draft) async {
    final loaded = draft ?? await _timerRepository.timeEntry;

    if (loaded == null) {
      if (!isClosed) emitEffect(const TimeEntrySummaryEffect.error());
      return;
    }

    final minutes = max(loaded.hours.inMinutes, 1);
    loaded.hours = Duration(minutes: minutes);
    timeEntry = loaded;

    if (isClosed) return;
    await _emitIdleState();

    // Comment suggestions are a nice-to-have. Only fetch them when we
    // can scope the request to the current work package; otherwise the
    // repository would run the query unscoped and pull up to
    // `pageSize` unrelated entries from across the user's entire time
    // entry history — wasted bandwidth and, worse, suggestions from
    // completely unrelated tickets.
    final workPackageIdString = loaded.workPackageHref.split('/').last;
    final workPackageId = int.tryParse(workPackageIdString);
    if (workPackageId == null) {
      if (isClosed) return;
      debugPrint(
        'Skipping comment suggestions: could not parse work package id '
        'from "${loaded.workPackageHref}"',
      );
      _commentSuggestions = const [];
      await _emitIdleState();
      return;
    }

    try {
      final timeEntries = await _timeEntriesRepository.list(
        workPackageId: workPackageId,
        pageSize: 100,
      );
      if (isClosed) return;

      final comments = timeEntries.map((e) => e.comment ?? '').toSet().toList();
      comments.remove('');
      _commentSuggestions = comments;
      await _emitIdleState();
    } catch (e) {
      if (isClosed) return;
      debugPrint('Failed to load comment suggestions: $e');
      _commentSuggestions = const [];
      await _emitIdleState();
    }
  }

  Future<void> updateTimeSpent(Duration timeSpent) async {
    timeEntry.hours = timeSpent;
    await _emitIdleState();
  }

  Future<void> updateComment(String comment) async {
    timeEntry.comment = comment;
  }

  Future<void> submit() async {
    if (isClosed) return;
    // Prevent duplicate submissions when the save button is tapped
    // multiple times before the first request completes.
    if (state is _Loading) return;
    emit(const TimeEntrySummaryState.loading());
    try {
      final submittedEntry = await _timerService.submit(timeEntry: timeEntry);
      if (isClosed) return;
      emitEffect(TimeEntrySummaryEffect.complete(timeEntry: submittedEntry));
    } catch (e) {
      if (isClosed) return;
      await _emitIdleState();
      emitEffect(const TimeEntrySummaryEffect.error());
    }
  }
}
