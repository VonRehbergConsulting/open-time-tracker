import 'package:flutter/cupertino.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization_checker/authorization_checker_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_page.dart';
import 'package:provider/provider.dart';

import '/models/timer_provider.dart';
import '/screens/timer_screen.dart';
import '/screens/work_packages_list/work_packages_list_screen.dart';
import '/models/time_entry.dart';
import '../transitions/slide_transition.dart';
import '/screens/time_entry_summary_screen.dart';
import '/screens/comment_suggestions_screen.dart';
import '/screens/instance_configuration_screen.dart';

class AppRouter {
  static void routeToTimer(
      BuildContext context, TimeEntry timeEntry, Widget currentScreen) {
    Provider.of<TimerProvider>(context, listen: false).setTimeEntry(timeEntry);
    const newScreen = TimerScreen();
    final route =
        SlideToRightTransition(toScreen: newScreen, fromScreen: currentScreen);
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToWorkPackagesList(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const WorkPackagesListScreen()),
    );
    Navigator.of(context).push(route);
  }

  static void routeToTimeEntriesListTemporary(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => TimeEntriesListPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToTimeEntrySummary(
      BuildContext context, TimeEntry timeEntry) {
    final route = CupertinoPageRoute(
      builder: ((context) => TimeEntrySummaryScreen(
            timeEntry: timeEntry,
          )),
    );
    Navigator.of(context).push(route);
  }

  static void routeToCommentSuggestions({
    required BuildContext context,
    required List<String> comments,
    required Function(String comment) handler,
  }) {
    final route = CupertinoPageRoute(
      builder: ((context) => CommentSuggestionsScreen(
            comments,
            ((comment) {
              handler(comment);
              Navigator.of(context).pop();
            }),
          )),
    );
    Navigator.of(context).push(route);
  }

  static void routeToInstanceConfiguration({
    required BuildContext context,
    required Function completion,
  }) {
    final route = CupertinoPageRoute(
      builder: ((context) => InstanceConfigurationScreen(
            () {
              completion();
              Navigator.of(context).pop();
            },
          )),
    );
    Navigator.of(context).push(route);
  }

  static void routeToAuth({required BuildContext context}) {
    final route = CupertinoPageRoute(
      builder: ((context) => AuthorizationPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToAuthCheck(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => AuthorizationCheckerPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }
}
