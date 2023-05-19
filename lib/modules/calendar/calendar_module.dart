import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/modules/calendar/domain/calendar_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/api_calendar_repository.dart';
import 'package:open_project_time_tracker/modules/calendar/infrastructure/graph_calendar_api.dart';
import 'package:open_project_time_tracker/modules/calendar/ui/calendar_bloc.dart';

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

  @injectable
  CalendarBloc calendarBloc(
    @Named('graph') AuthService graphAuthService,
    CalendarRepository calendarRepository,
  ) =>
      CalendarBloc(
        graphAuthService,
        calendarRepository,
      );
}
