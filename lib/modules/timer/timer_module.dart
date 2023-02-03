import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/app/storage/timer_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/local_timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_bloc.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_bloc.dart';

@module
abstract class TimerModule {
  @injectable
  TimerRepository timerRepository() => LocalTimerRepository(
        TimerStorage(PreferencesStorage()),
      );

  @injectable
  TimerBloc timerBloc(
    TimerRepository timerRepository,
  ) =>
      TimerBloc(
        timerRepository,
      );

  @injectable
  TimeEntrySummaryBloc timeEntrySummaryBloc(
    TimeEntriesRepository timeEntriesRepository,
    UserDataRepository userDataRepository,
    TimerRepository timerRepository,
  ) =>
      TimeEntrySummaryBloc(
        timeEntriesRepository,
        userDataRepository,
        timerRepository,
      );
}
