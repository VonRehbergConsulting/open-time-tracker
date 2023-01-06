import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/rest_api_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/helpers/preferences_storage.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/api_time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/local_settings_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/infrastructure/time_entries_api.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_bloc.dart';

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
  TimeEntriesRepository timeEntriesRepository(
    TimeEntriesApi timeEntriesApi,
  ) =>
      ApiTimeEntriesRepository(
        timeEntriesApi,
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
    AuthClient authClient,
  ) =>
      TimeEntriesListBloc(
        timeEntriesRepository,
        userDataRepository,
        settingsRepository,
        authClient,
      );
}
