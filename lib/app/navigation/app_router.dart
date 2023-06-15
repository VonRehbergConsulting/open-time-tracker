import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/di/inject.dart';
import 'package:open_project_time_tracker/app/navigation/app_router_bloc.dart';
import 'package:open_project_time_tracker/app/navigation/app_authorized_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc.dart';
import 'package:open_project_time_tracker/app/ui/widgets/error_screen.dart';
import 'package:open_project_time_tracker/app/ui/widgets/splash_screen.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        () => inject(instanceName: 'openProject'),
        () => inject(),
        () => inject(instanceName: 'openProject'),
      )..init(),
      builder: (context, state) {
        return state.when(
          loading: () => const SplashScreen(),
          authorized: () => const AppAuthorizedRouter(),
          unaurhorized: () => const AuthorizationPage(),
          error: () => ErrorScreen(
              text: AppLocalizations.of(context).generic_error,
              buttonText: AppLocalizations.of(context).generic_retry,
              action: () async {
                await context.read<AppRouterBloc>().retryAuthorization();
                setState(() {});
              }),
        );
      },
    );
  }
}
