import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/bloc_page.dart';
import 'package:open_project_time_tracker/helpers/app_router.dart';

import 'authorization_checker_bloc.dart';

class AuthorizationCheckerPage extends EffectBlocPage<AuthorizationCheckerBloc,
    AuthorizationCheckerState, AuthorizationCheckerEffect> {
  @override
  void onEffect(BuildContext context, AuthorizationCheckerEffect effect) {
    effect.when(
      authorization: () {
        print('Go to authorization');
        AppRouter.routeToAuth(context: context);
      },
      timeEntries: () {
        print('Go to time entries');
      },
      timer: () {
        print('Go to timer');
      },
    );
  }

  @override
  void onCreate(BuildContext context, AuthorizationCheckerBloc bloc) {
    super.onCreate(context, bloc);
    bloc.checkState();
  }

  @override
  Widget buildState(BuildContext context, AuthorizationCheckerState state) {
    return const Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }
}
