import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/timer_provider.dart';
import '/screens/timer_screen.dart';
import '/screens/work_packages_list/work_packages_list_screen.dart';
import '/models/time_entry.dart';

class AppRouter {
  static void routeToTimer(BuildContext context, TimeEntry timeEntry) {
    Provider.of<TimerProvider>(context, listen: false).timeEntry = timeEntry;
    final route = MaterialPageRoute(
      builder: ((context) => const TimerScreen()),
      fullscreenDialog: true,
    );
    // Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
    Navigator.of(context).push(route);
  }

  static void routeToWorkPackagesList(BuildContext context) {
    final route = MaterialPageRoute(
      builder: ((context) => const WorkPackagesListScreen()),
    );
    Navigator.of(context).push(route);
  }
}
