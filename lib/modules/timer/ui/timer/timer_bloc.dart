import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

part 'timer_bloc.freezed.dart';

@freezed
class TimerState with _$TimerState {
  const factory TimerState.idle({
    required Duration timeSpent,
    required String title,
    required String subtitle,
    required bool hasStarted,
    required bool isActive,
  }) = _Idle;
}

class TimerBloc extends Cubit<TimerState> {
  final TimerRepository _timerRepository;

  TimerBloc(this._timerRepository)
      : super(
          TimerState.idle(
            timeSpent: Duration(),
            title: '',
            subtitle: '',
            hasStarted: false,
            isActive: false,
          ),
        ) {
    loadData();
  }

  Future<void> loadData() async {
    final data = await Future.wait([
      _timerRepository.timeEntry,
      _timerRepository.hasStarted,
      _timerRepository.isActive,
    ]);
    try {
      final timeEntry = data[0] as TimeEntry;
      final hasStarted = data[1] as bool;
      final isActive = data[2] as bool;
      emit(
        TimerState.idle(
          timeSpent: timeEntry.hours,
          title: timeEntry.workPackageSubject,
          subtitle: timeEntry.projectTitle,
          hasStarted: hasStarted,
          isActive: isActive,
        ),
      );
    } catch (e) {
      print('Cannot load timer data: $e');
    }
  }

  Future<void> reset() async {
    await _timerRepository.reset();
  }

  Future<void> start() async {
    //
  }

  Future<void> stop() async {
    //
  }

  Future<void> finish() async {
    //
  }
}
