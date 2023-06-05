import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/app/storage/timer_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_notifications_service.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_service.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/api_timer_service.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/local_timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_bloc.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_bloc.dart';

@module
abstract class TimerModule {
  @lazySingleton
  TimerRepository timerRepository() => LocalTimerRepository(
        TimerStorage(PreferencesStorage()),
      );

  @lazySingleton
  TimerService timerService(
    TimeEntriesRepository timeEntriesRepository,
    UserDataRepository userDataRepository,
    TimerRepository timerRepository,
    CalendarNotificationsService calendarNotificationsService,
  ) =>
      ApiTimerService(
        timeEntriesRepository,
        userDataRepository,
        timerRepository,
        calendarNotificationsService,
      );

  @injectable
  TimerBloc timerBloc(
    TimerRepository timerRepository,
    CalendarNotificationsService calendarNotificationsService,
  ) =>
      TimerBloc(
        timerRepository,
        calendarNotificationsService,
      );

  @injectable
  TimeEntrySummaryBloc timeEntrySummaryBloc(
    TimeEntriesRepository timeEntriesRepository,
    TimerRepository timerRepository,
    TimerService timerService,
  ) =>
      TimeEntrySummaryBloc(
        timeEntriesRepository,
        timerRepository,
        timerService,
      );
}
