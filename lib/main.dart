import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/navigation/app_router.dart';
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'app/di/inject.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage(AssetImages.logo), context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 242),
        colorSchemeSeed: Color.fromRGBO(38, 92, 185, 1),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: AppRouter(),
    );
  }
}
