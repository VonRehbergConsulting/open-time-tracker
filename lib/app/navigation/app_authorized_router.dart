import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/navigation/app_authorized_router_bloc.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/modules/task_selection/ui/time_entries_list/time_entries_list_page.dart';
import 'package:open_project_time_tracker/modules/timer/ui/timer/timer_page.dart';

class AppAuthorizedRouter extends StatefulWidget {
  const AppAuthorizedRouter({super.key});

  @override
  State<AppAuthorizedRouter> createState() => _AppAuthorizedRouterState();
}

class _AppAuthorizedRouterState extends State<AppAuthorizedRouter> {
  @override
  Widget build(BuildContext context) {
    return InjectableBlocConsumer<
      AppAuthorizedRouterBloc,
      AppAuthorizedRouterState
    >(
      create: (context) =>
          AppAuthorizedRouterBloc(() => inject(), () => inject())..init(),
      builder: (context, state) {
        return state.when(
          initializing: () => const SplashScreen(),
          idle: (isTimerSet, isViewingToday) {
            // Only show timer page if a timer is set AND we're viewing today
            return (isTimerSet && isViewingToday)
                ? TimerPage()
                : const TimeEntriesListPage();
          },
        );
      },
    );
  }
}
