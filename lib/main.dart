// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_project_time_tracker/app/instances/domain/instances_repository.dart';
import 'package:open_project_time_tracker/app/services/analytics_service.dart';
import 'package:open_project_time_tracker/app/settings/domain/ui_settings_repository.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/navigation/app_router.dart';
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'package:open_project_time_tracker/app/ui/themes.dart';
import 'app/di/inject.dart';
import 'app/services/local_notification_service.dart';
import 'modules/calendar/domain/calendar_notifications_service.dart';

void main() async {
  configureDependencies();
  await dotenv.load();

  // Eagerly hydrate persisted repositories in parallel — both are
  // SharedPreferences reads with no interdependency, and both must
  // resolve before runApp() so the first frame sees:
  //   • Instances: any legacy single-instance credentials get migrated
  //     to the per-instance keyspace before the auth layer reads the
  //     token storage (otherwise the first refreshState() sees a null
  //     active id and briefly reports "not authenticated").
  //   • Settings: the persisted themeMode is available synchronously
  //     on the very first MaterialApp frame (avoids a light-mode
  //     flash on cold start when the user has picked dark).
  await Future.wait([
    inject<InstancesRepository>().load(),
    inject<UiSettingsRepository>().load(),
  ]);

  inject<LocalNotificationService>().setup();

  // Initialize analytics in background - don't block app startup
  // ignore: unawaited_futures
  inject<AnalyticsService>().initialize();

  runApp(
    CalendarNotificationsScheduler(inject<CalendarNotificationsService>()),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CalendarNotificationsScheduler extends StatefulWidget {
  final CalendarNotificationsService calendarNotificationsService;

  const CalendarNotificationsScheduler(
    this.calendarNotificationsService, {
    super.key,
  });

  @override
  State<CalendarNotificationsScheduler> createState() =>
      _CalendarNotificationsSchedulerState();
}

class _CalendarNotificationsSchedulerState
    extends State<CalendarNotificationsScheduler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _scheduleNotifications();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleNotifications();
    }
    super.didChangeAppLifecycleState(state);
  }

  _scheduleNotifications() async {
    try {
      await widget.calendarNotificationsService.removeNotifications();
      final context = navigatorKey.currentContext!;
      await widget.calendarNotificationsService.scheduleNotifications(
        AppLocalizations.of(context).notifications_calendar_title,
        AppLocalizations.of(context).notifications_calendar_body,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage(AssetImages.logo), context);
    final settings = inject<UiSettingsRepository>();
    return StreamBuilder<ThemeMode>(
      // Rebuild MaterialApp when the user flips the theme override in
      // the profile page. Seeded with the just-hydrated current mode
      // so the first frame already reflects the persisted choice.
      stream: settings.observeThemeMode(),
      initialData: settings.themeMode,
      builder: (context, snap) {
        final themeMode = snap.data ?? ThemeMode.system;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
            Locale('es'),
            Locale('fr'),
            Locale('tr'),
          ],
          title: 'Open Project Time Tracker',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: const AppRouter(),
        );
      },
    );
  }
}
