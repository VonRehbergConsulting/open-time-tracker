import 'package:flutter/cupertino.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/instance_configuration/instance_configuration_page.dart';
import 'package:open_project_time_tracker/modules/calendar/ui/calendar_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/analytics/analytics_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/notification_selection_list/notification_selection_list_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/projects_list/projects_list_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_filter/work_packages_filter_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/comment_suggestions_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_page.dart';

import '../main.dart';

class AppRouter {
  // TODO: rebuild routing
  static void routeToTimer(BuildContext context) {
    final route = CupertinoPageRoute(builder: ((context) => TimerPage()));
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static Future<TimeEntry?> routeToWorkPackagesList({
    required Project project,
  }) {
    final route = CupertinoPageRoute<TimeEntry>(
      builder: ((context) => WorkPackagesListPage(project)),
    );
    return navigatorKey.currentState!.push(route);
  }

  static void routeToTimeEntriesListTemporary(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const TimeEntriesListPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static Future<TimeEntry?> routeToTimeEntrySummary(BuildContext context) {
    final route = CupertinoPageRoute<TimeEntry>(
      builder: ((context) => TimeEntrySummaryPage()),
    );
    return Navigator.of(context).push(route);
  }

  static void routeToCommentSuggestions({
    required BuildContext context,
    required List<String> comments,
    required Function(String comment) handler,
  }) {
    final route = CupertinoPageRoute(
      builder: ((context) => CommentSuggestionsPage(comments, ((comment) {
        handler(comment);
        Navigator.of(context).pop();
      }))),
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
      builder: ((context) => const AuthorizationPage()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static void routeToAnalytics(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const AnalyticsPage()),
    );
    Navigator.of(context).push(route);
  }

  static void routeToCalendar(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const CalendarPage()),
    );
    Navigator.of(context).push(route);
  }

  static Future<void> showLoading(Future<void> Function() action) async {
    navigatorKey.currentState?.push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SplashScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
    try {
      await action();
      navigatorKey.currentState?.pop();
    } catch (e) {
      navigatorKey.currentState?.pop();
      rethrow;
    }
  }

  static void routeToNotificationSelectionList() {
    final route = CupertinoPageRoute(
      builder: ((context) => const NotificationSelectionListPage()),
    );
    navigatorKey.currentState?.push(route);
  }

  static void routeToWorkPackagesFilter({Function()? comppletion}) {
    final route = CupertinoPageRoute(
      builder: ((context) => WorkPackagesFilterPage(completion: comppletion)),
    );
    navigatorKey.currentState?.push(route);
  }

  static Future<TimeEntry?> routeToProjectsList() {
    final route = CupertinoPageRoute<TimeEntry>(
      builder: ((context) => const ProjectsListPage()),
    );
    return navigatorKey.currentState!.push(route);
  }
}
