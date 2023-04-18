import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';
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
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 64.0,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 4),
              LayoutBuilder(
                builder: (context, constraints) => Container(
                  width: constraints.maxWidth * 0.3,
                  child: Image.asset(AssetImages.logo),
                ),
              ),
              Spacer(flex: 3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: state.canAuthorize
                        ? context.read<AuthorizationBloc>().authorize
                        : null,
                    text: AppLocalizations.of(context).authorization_log_in,
                  ),
                  CupertinoButton(
                    onPressed: () => AppRouter.routeToInstanceConfiguration(
                      context: context,
                      completion: context
                          .read<AuthorizationBloc>()
                          .checkInstanceConfiguration,
                    ),
                    child: Text(
                      AppLocalizations.of(context)
                          .authorization_configure_instance,
                    ),
                  ),
                ],
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
