import 'package:flutter/cupertino.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization_checker/authorization_checker_page.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/instance_configuration/instance_configuration_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/comment_suggestions_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_page.dart';

class AppRouter {
  // TODO: rebuild routing
  static void routeToTimer(
    BuildContext context,
  ) {
    final route = CupertinoPageRoute(
      builder: ((context) => TimerPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToWorkPackagesList(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => WorkPackagesListPage()),
    );
    Navigator.of(context).push(route);
  }

  static void routeToTimeEntriesListTemporary(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => TimeEntriesListPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToTimeEntrySummary(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => TimeEntrySummaryPage()),
    );
    Navigator.of(context).push(route);
  }

  static void routeToCommentSuggestions({
    required BuildContext context,
    required List<String> comments,
    required Function(String comment) handler,
  }) {
    final route = CupertinoPageRoute(
      builder: ((context) => CommentSuggestionsPage(
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
      builder: ((context) => InstanceConfigurationPage(completion)),
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
