import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/modules/calendar/ui/calendar_bloc.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app/ui/widgets/filled_button.dart';

class CalendarPage extends BlocPage<CalendarBloc, CalendarBlocState> {
  @override
  Widget buildState(BuildContext context, CalendarBlocState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello there'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: FilledButton(
            onPressed: context.read<CalendarBloc>().testGraph,
            text: AppLocalizations.of(context).calendar_connect,
          ),
        ),
      ),
    );
  }
}
