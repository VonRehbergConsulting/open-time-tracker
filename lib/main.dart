import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/navigation/app_router.dart';
import 'package:open_project_time_tracker/app/services/local_notification_service.dart';
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'app/di/inject.dart';

void main() async {
  configureDependencies();
  await dotenv.load();
  // TODO: remove notifications setup
  inject<LocalNotificationService>().setup();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage(AssetImages.logo), context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('de'),
      ],
      title: 'Open Project Time Tracker',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 243, 243, 243),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 243, 243, 243),
        colorSchemeSeed: Color.fromRGBO(38, 92, 185, 1),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: AppRouter(),
    );
  }
}
