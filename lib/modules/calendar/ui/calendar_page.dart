import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/ui/asset_images.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/app/ui/widgets/promo_text_style.dart';
import 'package:open_project_time_tracker/modules/calendar/ui/calendar_bloc.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

import '../../../app/ui/widgets/filled_button.dart';

class CalendarPage extends BlocPage<CalendarBloc, CalendarBlocState> {
  const CalendarPage({super.key});

  @override
  void onCreate(BuildContext context, CalendarBloc bloc) {
    super.onCreate(context, bloc);
    bloc.init();
  }

  @override
  Widget buildState(BuildContext context, CalendarBlocState state) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).calendar_title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...state.when<List<Widget>>(
              loading: () => [const Center(child: ActivityIndicator())],
              landing: () => _body(context, false),
              calendar: () => _body(context, true),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, bool isAuthorized) {
    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.7;
    const spacing = 32.0;

    return [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: deviceSize.width * 0.6,
              child: Image.asset(AssetImages.microsoftCalendar),
            ),
            if (isAuthorized)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: deviceSize.width * 0.08,
              ),
            const SizedBox(height: spacing),
            Text(
              isAuthorized
                  ? AppLocalizations.of(context).calendar_connected_1
                  : AppLocalizations.of(context).calendar_promo_1,
              style: const PromoTextStyle(),
            ),
            const SizedBox(height: spacing),
            Text(
              isAuthorized
                  ? AppLocalizations.of(context).calendar_connected_2
                  : AppLocalizations.of(context).calendar_promo_2,
              style: const PromoTextStyle(),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: SizedBox(
          width: buttonWidth,
          child: FilledButton(
            onPressed: isAuthorized
                ? context.read<CalendarBloc>().unauthorize
                : context.read<CalendarBloc>().authorize,
            text: isAuthorized
                ? AppLocalizations.of(context).calendar_disconnect
                : AppLocalizations.of(context).calendar_connect,
          ),
        ),
      ),
    ];
  }
}
