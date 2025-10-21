// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_project_time_tracker/app/services/analytics_service.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/navigation/app_router.dart';
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'app/di/inject.dart';
import 'app/services/local_notification_service.dart';
import 'modules/calendar/domain/calendar_notifications_service.dart';

void main() async {
  configureDependencies();
  await dotenv.load();
  await inject<AnalyticsService>().initialize(consentGiven: true);
  inject<LocalNotificationService>().setup();
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
    const themeColor = Color.fromRGBO(38, 92, 185, 1);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de')],
      title: 'Open Project Time Tracker',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 243, 243, 243),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 249, 249, 249),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: themeColor,
        fontFamily: 'Cupertino',
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: themeColor),
        ),
      ),
      home: const AppRouter(),
    );
  }
}
