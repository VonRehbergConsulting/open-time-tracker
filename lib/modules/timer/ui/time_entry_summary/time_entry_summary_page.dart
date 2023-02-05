import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/app_router.dart';
import 'package:open_project_time_tracker/app/ui/bloc/bloc_page.dart';
import 'package:open_project_time_tracker/app/ui/widgets/activity_indicator.dart';
import 'package:open_project_time_tracker/app/ui/widgets/time_picker.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';
import 'package:open_project_time_tracker/modules/timer/ui/time_entry_summary/time_entry_summary_bloc.dart';

// ignore: must_be_immutable
class TimeEntrySummaryPage extends EffectBlocPage<TimeEntrySummaryBloc,
    TimeEntrySummaryState, TimeEntrySummaryEffect> {
  final _form = GlobalKey<FormState>();
  final _timeFieldController = TextEditingController();
  final _commentFieldController = TextEditingController();

  Duration? timeSpent;

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
                final duration = Duration(
                  hours: value.hour,
                  minutes: value.minute,
                );
                context.read<TimeEntrySummaryBloc>().updateTimeSpent(duration);
              },
            )),
      );
    }
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

  Future<void> _submit(BuildContext context) async {
    _form.currentState?.save();
    context.read<TimeEntrySummaryBloc>().submit();
  }

  @override
  void onEffect(BuildContext context, TimeEntrySummaryEffect effect) {
    effect.when(
      complete: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }

  @override
  void onStateChange(BuildContext context, TimeEntrySummaryState state) {
    super.onStateChange(context, state);
    state.whenOrNull(
      idle: (
        title,
        projectTitle,
        timeSpent,
        comment,
        commentSuggestions,
      ) {
        this.timeSpent = timeSpent;
        // TODO: fix comment lose after hot reload
        _commentFieldController.text = comment ?? '';
      },
    );
  }

  @override
  Widget buildState(BuildContext context, TimeEntrySummaryState state) {
    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.35;

    final Widget body = state.when(
      loading: () => Center(child: ActivityIndicator()),
      idle: (
        title,
        projectTitle,
        timeSpent,
        comment,
        commentSuggestions,
      ) {
        this.timeSpent = timeSpent;
        _timeFieldController.text = timeSpent.shortWatch();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(labelText: 'Task'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: projectTitle,
                        decoration: const InputDecoration(labelText: 'Project'),
                        enabled: false,
                      ),
                      TextFormField(
                        controller: _timeFieldController,
                        decoration:
                            const InputDecoration(labelText: 'Time spent'),
                        readOnly: true,
                        onTap: () => _showTimePicker(context),
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _commentFieldController,
                        decoration: InputDecoration(
                          labelText: 'Comment',
                          suffixIcon: commentSuggestions.isEmpty
                              ? const CupertinoActivityIndicator()
                              : commentSuggestions.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () => _showCommentSuggestions(
                                            context,
                                            commentSuggestions,
                                          ),
                                      icon: const Icon(Icons.more_horiz)),
                        ),
                        readOnly: false,
                        onChanged: (_) => context
                            .read<TimeEntrySummaryBloc>()
                            .updateComment(_commentFieldController.text),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () => _submit(context),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: body,
    );
  }
}
