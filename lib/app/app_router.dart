import 'package:flutter/cupertino.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/navigation/app_authorized_router.dart';
import 'package:open_project_time_tracker/app/storage/app_state_repository.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/extensions/date_time.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/instance_configuration/instance_configuration_page.dart';
import 'package:open_project_time_tracker/modules/profile/ui/profile_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/projects_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/domain/time_entries_repository.dart';
import 'package:open_project_time_tracker/modules/timer/domain/timer_repository.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/notification_selection_list/notification_selection_list_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/projects_list/projects_list_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_filter/work_packages_filter_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/work_packages_list/work_packages_list_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/comment_suggestions_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/monthly_overview/monthly_overview_page.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/export_report/export_report_page.dart';

import '../main.dart';

class AppRouter {
  static Route<void> _timerRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => const TimerPage(),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final positionAnimation = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curvedAnimation);

        final opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(curvedAnimation);

        return FadeTransition(
          opacity: opacityAnimation,
          child: SlideTransition(
            position: positionAnimation,
            child: child,
          ),
        );
      },
    );
  }

  // Timer is presented via a custom vertical slide+fade transition rather
  // than the default Cupertino horizontal push. This route is used both as
  // an initial presentation and via [routeToTimer] for reopening the
  // running timer, so callers use the top-level Navigator (see [routeToTimer]).
  static void routeToTimer([BuildContext? context]) {
    navigatorKey.currentState?.push(_timerRoute());
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
      builder: ((context) => const AppAuthorizedRouter()),
    );
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  static Future<bool> redirectToTimerIfActiveToday({
    required BuildContext context,
    DateTime? selectedDate,
  }) async {
    final timerRepository = inject<TimerRepository>();
    final appStateRepository = inject<AppStateRepository>();

    final isTimerActive = await timerRepository.isActive;
    if (!isTimerActive) {
      return false;
    }

    final currentSelectedDate =
        selectedDate ?? await appStateRepository.selectedDate;
    final isViewingToday =
        currentSelectedDate == null || currentSelectedDate.isToday;

    if (!isViewingToday) {
      return false;
    }

    if (context.mounted) {
      routeToTimer();
    }
    return true;
  }

  static Future<TimeEntry?> routeToTimeEntrySummary(
    BuildContext context, {
    TimeEntry? timeEntry,
  }) async {
    final shouldRedirect = await redirectToTimerIfActiveToday(context: context);
    if (shouldRedirect) {
      return null;
    }

    if (!context.mounted) {
      return null;
    }

    final route = CupertinoPageRoute<TimeEntry>(
      builder: ((context) => TimeEntrySummaryPage(draft: timeEntry)),
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

  static void routeToProfile(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const ProfilePage()),
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

  static void routeToMonthlyOverview(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const MonthlyOverviewPage()),
    );
    Navigator.of(context).push(route);
  }

  static void routeToExportReport(BuildContext context) {
    final route = CupertinoPageRoute(
      builder: ((context) => const ExportReportPage()),
    );
    Navigator.of(context).push(route);
  }
}
