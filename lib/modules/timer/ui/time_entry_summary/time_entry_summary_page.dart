import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide FilledButton;
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/app/ui/widgets/filled_button.dart';
import 'package:open_project_time_tracker/app/ui/widgets/time_picker.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_bloc.dart';

import 'package:open_project_time_tracker/l10n/app_localizations.dart';

// ignore: must_be_immutable
class TimeEntrySummaryPage
    extends
        EffectBlocPage<
          TimeEntrySummaryBloc,
          TimeEntrySummaryState,
          TimeEntrySummaryEffect
        > {
  final _form = GlobalKey<FormState>();
  final _timeFieldController = TextEditingController();
  final _commentFieldController = TextEditingController();

  Duration? timeSpent;

  TimeEntrySummaryPage({super.key});

  void _showTimePicker(BuildContext context) {
    if (timeSpent != null) {
      final hours = timeSpent!.inHours;
      final minutes = timeSpent!.inMinutes.remainder(60);
      showCupertinoModalPopup(
        context: context,
        builder: ((_) => TimePicker(
          hours: hours,
          minutes: minutes,
          onTimeChanged: (value) {
            final duration = Duration(hours: value.hour, minutes: value.minute);
            context.read<TimeEntrySummaryBloc>().updateTimeSpent(duration);
          },
        )),
      );
    }
  }

  Future<void> _submit(BuildContext context) async {
    _form.currentState?.save();
    context.read<TimeEntrySummaryBloc>().submit();
  }

  void _showCommentSuggestions(
    BuildContext context,
    List<String> commentSuggestions,
  ) {
    AppRouter.routeToCommentSuggestions(
      context: context,
      comments: commentSuggestions,
      handler: (comment) {
        context.read<TimeEntrySummaryBloc>().updateComment(comment);
        _commentFieldController.text = comment;
      },
    );
  }

  @override
  void onEffect(BuildContext context, TimeEntrySummaryEffect effect) {
    effect.when(
      complete: (timeEntry) {
        // Just pop back with the created entry - let it bubble up the navigation stack
        Navigator.of(context).pop(timeEntry);
      },
      error: () {
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context).generic_error),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  @override
  void onStateChange(BuildContext context, TimeEntrySummaryState state) {
    super.onStateChange(context, state);
    state.whenOrNull(
      idle: (title, projectTitle, timeSpent, comment, commentSuggestions) {
        this.timeSpent = timeSpent;
        // TODO: fix comment lose after hot reload
        _commentFieldController.text = comment ?? '';
      },
    );
  }

  @override
  Widget buildState(BuildContext context, TimeEntrySummaryState state) {
    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.7;

    final Widget body = state.when(
      loading: () => const Center(child: ActivityIndicator()),
      idle: (title, projectTitle, timeSpent, comment, commentSuggestions) {
        this.timeSpent = timeSpent;
        _timeFieldController.text = timeSpent.shortWatch();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: title,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).time_entry_summary_task,
                      ),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: projectTitle,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).time_entry_summary_project,
                      ),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _timeFieldController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).time_entry_summary_time_spent,
                      ),
                      readOnly: true,
                      onTap: () => _showTimePicker(context),
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _commentFieldController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        ).time_entry_summary_comment,
                        suffixIcon: commentSuggestions == null
                            ? SizedBox(
                                width: IconTheme.of(context).size,
                                height: IconTheme.of(context).size,
                                child: const ActivityIndicator(),
                              )
                            : commentSuggestions.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () => _showCommentSuggestions(
                                  context,
                                  commentSuggestions,
                                ),
                                icon: const Icon(Icons.more_horiz),
                              ),
                      ),
                      readOnly: false,
                      onChanged: (_) => context
                          .read<TimeEntrySummaryBloc>()
                          .updateComment(_commentFieldController.text),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: SizedBox(
                  width: buttonWidth,
                  child: FilledButton(
                    onPressed: () => _submit(context),
                    text: AppLocalizations.of(context).generic_save,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).time_entry_summary_title),
      ),
      body: body,
    );
  }
}
