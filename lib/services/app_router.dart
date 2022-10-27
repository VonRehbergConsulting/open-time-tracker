import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/helpers/slide_right_route.dart';
import 'package:open_project_time_tracker/screens/time_entries_list/time_entries_list_screen.dart';
import 'package:provider/provider.dart';

import '/models/timer_provider.dart';
import '/screens/timer_screen.dart';
import '/screens/work_packages_list/work_packages_list_screen.dart';
import '/models/time_entry.dart';

class AppRouter {
  static void routeToTimer(BuildContext context, TimeEntry timeEntry) {
    Provider.of<TimerProvider>(context, listen: false).timeEntry = timeEntry;
    final route = CupertinoPageRoute(
      builder: ((context) => const TimerScreen()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToWorkPackagesList(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const WorkPackagesListScreen()),
    );
    Navigator.of(context).push(route);
  }

  static void routeToTimeEntriesList(
      BuildContext context, Widget currentScreen) {
    const newScreen = TimeEntriesListScreen();
    final route =
        EnterExitRoute(exitScreen: currentScreen, enterScreen: newScreen);
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }
}
