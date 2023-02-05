import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_bloc.dart';

class AuthorizationPage extends EffectBlocPage<AuthorizationBloc,
    AuthorizationState, AuthorizationEffect> {
  @override
  void onEffect(BuildContext context, AuthorizationEffect effect) {
    effect.when(
      error: ((message) {
        // TODO: show error
      }),
    );
  }

  @override
  void onCreate(BuildContext context, AuthorizationBloc bloc) {
    super.onCreate(context, bloc);
    bloc.checkInstanceConfiguration();
  }

  @override
  Widget buildState(
    BuildContext context,
    AuthorizationState state,
  ) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/open_project_logo.png'),
              Column(
                children: [
                  CupertinoButton.filled(
                    onPressed: state.canAuthorize
                        ? context.read<AuthorizationBloc>().authorize
                        : null,
                    child: const Text('Log in'),
                  ),
                  CupertinoButton(
                    onPressed: () => AppRouter.routeToInstanceConfiguration(
                      context: context,
                      completion: context
                          .read<AuthorizationBloc>()
                          .checkInstanceConfiguration,
                    ),
                    child: const Text('Configure instance'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
