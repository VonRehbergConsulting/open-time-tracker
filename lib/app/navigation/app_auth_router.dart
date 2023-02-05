import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/navigation/app_auth_router_bloc.dart';
import 'package:open_project_time_tracker/app/navigation/app_authorized_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  Widget build(BuildContext context) {
    return InjectableBlocConsumer<AppRouterBloc, AppRouterState>(
      create: (context) => AppRouterBloc(
        () => inject(),
        () => inject(),
      )..init(),
      builder: (context, state) {
        return state.when(
          loading: () => const SplashScreen(),
          authorized: () => AppAuthorizedRouter(),
          unaurhorized: () => AuthorizationPage(),
        );
      },
    );
  }
}
