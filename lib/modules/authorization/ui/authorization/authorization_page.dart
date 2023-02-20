import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/modules/authorization/ui/authorization/authorization_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthorizationPage extends EffectBlocPage<AuthorizationBloc,
    AuthorizationState, AuthorizationEffect> {
  @override
  void onEffect(BuildContext context, AuthorizationEffect effect) {
    effect.when(
      error: (() {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context).generic_error),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    child:
                        Text(AppLocalizations.of(context).authorization_log_in),
                  ),
                  CupertinoButton(
                    onPressed: () => AppRouter.routeToInstanceConfiguration(
                      context: context,
                      completion: context
                          .read<AuthorizationBloc>()
                          .checkInstanceConfiguration,
                    ),
                    child: Text(AppLocalizations.of(context)
                        .authorization_configure_instance),
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
