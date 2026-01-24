import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/services/local_notification_service.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_connection_service.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_notifications_service.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/api_calendar_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/graph_calendar_api.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/local_calendar_notifications_service.dart';

import '../../app/api/api_client.dart';
import '../../app/auth/domain/auth_service.dart';
import 'infrastructure/graph_user_api.dart';

@module
abstract class CalendarModule {
  @lazySingleton
  GraphCalendarApi calendarApi(
    @Named('graph') ApiClient client,
  ) =>
      GraphCalendarApi(
        client.dio,
      );
  @lazySingleton
  GraphUserApi userApi(
    @Named('graph') ApiClient client,
  ) =>
      GraphUserApi(
        client.dio,
      );

  @lazySingleton
  CalendarRepository calendarRepository(
    GraphCalendarApi timeEntriesApi,
    GraphUserApi graphUserApi,
  ) =>
      ApiCalendarRepository(
        timeEntriesApi,
        graphUserApi,
      );

  @lazySingleton
  CalendarConnectionService calendarConnectionService(
    @Named('graph') AuthService graphAuthService,
    LocalNotificationService localNotificationService,
  ) =>
      CalendarConnectionService(
        graphAuthService,
        localNotificationService,
      );

  @lazySingleton
  CalendarNotificationsService calendarNotificationsService(
    LocalNotificationService localNotificationService,
    CalendarRepository calendarRepository,
  ) =>
      LocalCalendarNotificationsService(
        localNotificationService,
        calendarRepository,
      );
}
