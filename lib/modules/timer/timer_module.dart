import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/helpers/preferences_storage.dart';
import 'package:open_project_time_tracker/helpers/timer_storage.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/local_timer_repository.dart';
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
}
