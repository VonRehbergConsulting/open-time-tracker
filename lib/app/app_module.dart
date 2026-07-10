// removed flutter_appauth dependency; using manual OAuth flow instead
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:open_project_time_tracker/app/api/rest_api_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_client.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_service.dart';
import 'package:open_project_time_tracker/app/auth/domain/auth_token_storage.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/active_instance_configuration_repository.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_auth_service.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/oauth_client.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/open_project_auth_client_data.dart';
import 'package:open_project_time_tracker/app/auth/infrastructure/secure_auth_token_storage.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/instances/domain/instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/instances/infrastructure/default_instance_switcher.dart';
import 'package:open_project_time_tracker/app/instances/infrastructure/local_instances_repository.dart';
import 'package:open_project_time_tracker/app/live_activity/domain/live_activity_manager.dart';
import 'package:open_project_time_tracker/app/live_activity/infrastructure/default_live_activity_manager.dart';
import 'package:open_project_time_tracker/app/services/analytics_service.dart';
import 'package:open_project_time_tracker/app/services/local_notification_service.dart';
import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
import 'package:open_project_time_tracker/app/storage/app_state_storage.dart';
import 'package:open_project_time_tracker/app/storage/local_app_state_repository.dart';
import 'package:open_project_time_tracker/app/storage/preferences_storage.dart';
import 'package:open_project_time_tracker/app/auth/domain/instance_configuration_repository.dart';
import 'package:open_project_time_tracker/modules/authorization/domain/user_data_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/timer/infrastructure/live_activity_coordinator.dart';

import '../modules/calendar/domain/calendar_notifications_service.dart';
import 'api/api_client.dart';
import 'auth/domain/auth_client_data.dart';

@module
abstract class AppModule {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  @lazySingleton
  InstancesRepository instancesRepository() => LocalInstancesRepository(
    // Lazy hook: resolves the token storage from GetIt at the moment
    // the migration actually runs (after both singletons are wired).
    onLegacyTokenMigration: (newInstanceId, legacyAccess, legacyRefresh) async {
      final storage =
          inject<AuthTokenStorage>(instanceName: 'openProject')
              as SecureAuthTokenStorage;
      await storage.migrateLegacyTokens(newInstanceId);
    },
  );

  @Named('openProject')
  @lazySingleton
  AuthTokenStorage authTokenStorage() => SecureAuthTokenStorage.withKeys(
    const FlutterSecureStorage(),
    accessTokenKey: _accessTokenKey,
    refreshTokenKey: _refreshTokenKey,
    // Lazy resolver: keeps SecureAuthTokenStorage decoupled from
    // InstancesRepository at construction time (they would otherwise
    // form a DI cycle).
    resolveActiveInstanceId: () =>
        inject<InstancesRepository>().current.activeInstanceId,
  );

  @Named('openProject')
  @lazySingleton
  AuthService authService(
    @Named('openProject') AuthClient authClient,
    @Named('openProject') AuthTokenStorage authTokenStorage,
  ) => OAuthAuthService(authClient, authTokenStorage);

  @Named('openProject')
  @injectable
  AuthClientData authClientData(
    @Named('openProject')
    InstanceConfigurationReadRepository instanceConfigurationRepository,
  ) => OpenProjectAuthClientData(instanceConfigurationRepository);

  @Named('openProject')
  @injectable
  AuthClient authClient(
    @Named('openProject') AuthTokenStorage authTokenStorage,
    @Named('openProject') AuthClientData authClientData,
  ) => OAuthClient(authClientData);

  @Named('openProject')
  @injectable
  InstanceConfigurationReadRepository instanceConfigurationReadRepository(
    InstancesRepository instancesRepository,
  ) => ActiveInstanceConfigurationRepository(instancesRepository);

  @lazySingleton
  InstanceSwitcher instanceSwitcher(
    InstancesRepository instancesRepository,
    TimerRepository timerRepository,
    @Named('openProject') AuthService authService,
    UserDataRepository userDataRepository,
    LiveActivityCoordinator liveActivityCoordinator,
  ) => DefaultInstanceSwitcher(
    instancesRepository,
    timerRepository,
    authService,
    userDataRepository,
    liveActivityCoordinator,
  );

  @Named('openProject')
  @injectable
  ApiClient apiClient(
    @Named('openProject')
    InstanceConfigurationReadRepository instanceConfigurationRepository,
    @Named('openProject') AuthTokenStorage authTokenStorage,
    @Named('openProject') AuthClient authClient,
    @Named('openProject') AuthService authService,
    @Named('graph') AuthService graphAuthService,
    CalendarNotificationsService calendarNotificationsService,
  ) => RestApiClient(
    instanceConfigurationRepository,
    authTokenStorage,
    authClient,
    () {
      graphAuthService.logout();
      authService.logout();
      calendarNotificationsService.removeNotifications();
    },
  );

  @lazySingleton
  LocalNotificationService localNotificationService(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) => LocalNotificationService(flutterLocalNotificationsPlugin);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin() =>
      FlutterLocalNotificationsPlugin();

  @lazySingleton
  LiveActivityManager liveActivityManager() => DefaultLiveActivityManager(
    channelKey: 'vonrehberg.timetracker.live-activity',
  );

  @lazySingleton
  AnalyticsService analyticsService() => AnalyticsService();

  @lazySingleton
  AppStateStorage appStateStorage() => AppStateStorage(PreferencesStorage());

  @lazySingleton
  AppStateRepository appStateRepository(AppStateStorage appStateStorage) =>
      LocalAppStateRepository(appStateStorage);
}


