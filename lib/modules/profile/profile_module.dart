import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_connection_service.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_notifications_service.dart';
import 'package:open_project_time_tracker/modules/profile/ui/profile_bloc.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/settings_repository.dart';

@module
abstract class ProfileModule {
  @injectable
  ProfileBloc profileBloc(
    @Named('openProject') AuthService authService,
    CalendarNotificationsService calendarNotificationsService,
    UserDataRepository userDataRepository,
    CalendarConnectionService calendarConnectionService,
    SettingsRepository settingsRepository,
  ) => ProfileBloc(
    authService,
    calendarNotificationsService,
    userDataRepository,
    calendarConnectionService,
    settingsRepository,
  );
}
