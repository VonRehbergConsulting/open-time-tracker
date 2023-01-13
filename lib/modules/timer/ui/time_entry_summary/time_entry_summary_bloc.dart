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
  }) = _Idle;
}

@freezed
class TimeEntrySummaryEffect with _$TimeEntrySummaryEffect {
  const factory TimeEntrySummaryEffect.complete() = _Complete;
}

class TimeEntrySummaryBloc
    extends EffectCubit<TimeEntrySummaryState, TimeEntrySummaryEffect> {
  TimeEntriesRepository _timeEntriesRepository;
  UserDataRepository _userDataRepository;
  TimerRepository _timerRepository;

  late TimeEntry timeEntry;

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
      ),
    );
  }

  Future<void> _init() async {
    final timeEntry = await _timerRepository.timeEntry;
    if (timeEntry != null) {
      this.timeEntry = timeEntry;
      _emitIdleState();
    } else {
      // TODO: show error
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
      print(e);
    }
  }
}
