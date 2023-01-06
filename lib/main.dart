import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization_checker/authorization_checker_page.dart';
import 'app/di/inject.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(
        const AssetImage('assets/images/open_project_logo.png'), context);
    return MaterialApp(
      title: 'Open Project Time Tracker',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 242),
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: AuthorizationCheckerPage(),
    );
  }
}
