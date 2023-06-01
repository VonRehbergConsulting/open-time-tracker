import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/modules/calendar/ui/calendar_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/ui/widgets/filled_button.dart';

class CalendarPage extends BlocPage<CalendarBloc, CalendarBlocState> {
  @override
  void onCreate(BuildContext context, CalendarBloc bloc) {
    super.onCreate(context, bloc);
    bloc.init();
  }

  @override
  Widget buildState(BuildContext context, CalendarBlocState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).calendar_title),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: state.when(
          loading: () => Center(
            child: ActivityIndicator(),
          ),
          landing: () => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Awesome landing text'),
              FilledButton(
                onPressed: context.read<CalendarBloc>().authorize,
                text: AppLocalizations.of(context).calendar_connect,
              ),
            ],
          ),
          calendar: () => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Awesome, now you will recieve notifications!'),
              FilledButton(
                onPressed: context.read<CalendarBloc>().unauthorize,
                text: AppLocalizations.of(context).calendar_disconnect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
