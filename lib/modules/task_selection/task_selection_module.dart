import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/rest_api_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/work_packages_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/api_time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/api_work_packages_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/local_settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/time_entries_api.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/work_packages_api.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_bloc.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';

@module
abstract class TaskSelectionModule {
  @injectable
  TimeEntriesApi timeEntriesApi(
    RestApiClient client,
  ) =>
      TimeEntriesApi(
        client.dio,
      );

  @injectable
  WorkPackagesApi workPackagesApi(
    RestApiClient client,
  ) =>
      WorkPackagesApi(
        client.dio,
      );

  @injectable
  TimeEntriesRepository timeEntriesRepository(
    TimeEntriesApi timeEntriesApi,
  ) =>
      ApiTimeEntriesRepository(
        timeEntriesApi,
      );

  @injectable
  WorkPackagesRepository workPackagesRepository(
    WorkPackagesApi workPackagesApi,
  ) =>
      ApiWorkPackagesRepository(
        workPackagesApi,
      );

  @injectable
  SettingsRepository settingsRepository() => LocalSettingsRepository(
        PreferencesStorage(),
      );

  @injectable
  TimeEntriesListBloc timeEntriesListBloc(
    TimeEntriesRepository timeEntriesRepository,
    UserDataRepository userDataRepository,
    SettingsRepository settingsRepository,
    AuthService authService,
    TimerRepository timerRepository,
  ) =>
      TimeEntriesListBloc(
        timeEntriesRepository,
        userDataRepository,
        settingsRepository,
        authService,
        timerRepository,
      );

  @injectable
  WorkPackagesListBloc workPackagesListBloc(
    WorkPackagesRepository workPackagesRepository,
    UserDataRepository userDataRepository,
    TimerRepository timerRepository,
  ) =>
      WorkPackagesListBloc(
        workPackagesRepository,
        userDataRepository,
        timerRepository,
      );
}
