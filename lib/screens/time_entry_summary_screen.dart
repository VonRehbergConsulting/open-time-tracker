import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/models/timer_provider.dart';
import 'package:provider/provider.dart';

import '/models/time_entries_provider.dart';
import '/models/time_entry.dart';
import '/models/user_data_provider.dart';
import '/helpers/app_router.dart';
import '/extensions/duration.dart';
import '../app/ui/widgets/activity_indicator.dart';
import '../app/ui/widgets/time_picker.dart';

class TimeEntrySummaryScreen extends StatefulWidget {
  final TimeEntry timeEntry;
  const TimeEntrySummaryScreen({
    super.key,
    required this.timeEntry,
  });

  @override
  State<TimeEntrySummaryScreen> createState() => _TimeEntrySummaryScreenState();
}

class _TimeEntrySummaryScreenState extends State<TimeEntrySummaryScreen> {
  // Properties

  final _form = GlobalKey<FormState>();
  final _timeFieldController = TextEditingController();
  final _commentFieldController = TextEditingController();

  var _isLoading = false;

  List<String>? _commentSuggestions;

  // Private methods

  void _submit(BuildContext context) async {
    final userId = Provider.of<UserDataProvider>(context, listen: false).userId;
    if (userId == null) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.timeEntry.id == null) {
        await Provider.of<TimeEntriesProvider>(context, listen: false)
            .create(timeEntry: widget.timeEntry, userId: userId);
      } else {
        await Provider.of<TimeEntriesProvider>(context, listen: false)
            .update(timeEntry: widget.timeEntry);
      }
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      // AppRouter.routeToTimeEntriesList(context, widget, timerProvider.reset);
    } catch (error) {
      showDialog(
        context: context,
        builder: ((context) => CupertinoAlertDialog(
              title: const Text('Unable to log your work'),
              content: const Text('Please try again later'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            )),
      );
      setState(() {
        _isLoading = false;
      });
      print('Error while creating time entry');
    }
  }

  void _showTimePicker() {
    final hours = widget.timeEntry.hours.inHours;
    final minutes = widget.timeEntry.hours.inMinutes.remainder(60);
    showCupertinoModalPopup(
      context: context,
      builder: ((context) => TimePicker(
            hours: hours,
            minutes: minutes,
            onTimeChanged: ((value) {
              setState(() {
                widget.timeEntry.hours = Duration(
                  hours: value.hour,
                  minutes: value.minute,
                );
              });
            }),
          )),
    );
  }

  void _showCommentSuggestions(BuildContext context) {
    AppRouter.routeToCommentSuggestions(
      context: context,
      comments: _commentSuggestions ?? [],
      handler: (comment) {
        setState(() {
          _commentFieldController.text = comment;
        });
      },
    );
  }

  void _loadCommentSuggestions() async {
    final workPackageIdString =
        widget.timeEntry.workPackageHref.split('/').last;
    final workPackageId = int.tryParse(workPackageIdString);
    if (workPackageId == null) {
      return;
    }
    final comments =
        await Provider.of<TimeEntriesProvider>(context, listen: false)
            .loadComments(workPackageId: workPackageId);
    setState(() {
      _commentSuggestions = comments;
    });
  }

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _commentFieldController.text = widget.timeEntry.comment ?? '';
    widget.timeEntry.hours = widget.timeEntry.hours.roundedToMinutes;
    _loadCommentSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    _timeFieldController.text = widget.timeEntry.hours.shortWatch();

    final deviceSize = MediaQuery.of(context).size;
    final buttonWidth = deviceSize.width * 0.35;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: _isLoading
          ? const Center(child: ActivityIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: widget.timeEntry.workPackageSubject,
                            decoration:
                                const InputDecoration(labelText: 'Task'),
                            enabled: false,
                          ),
                          TextFormField(
                            initialValue: widget.timeEntry.projectTitle,
                            decoration:
                                const InputDecoration(labelText: 'Project'),
                            enabled: false,
                          ),
                          TextFormField(
                            controller: _timeFieldController,
                            decoration:
                                const InputDecoration(labelText: 'Time spent'),
                            readOnly: true,
                            onTap: () => _showTimePicker(),
                          ),
                          TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: _commentFieldController,
                            decoration: InputDecoration(
                              labelText: 'Comment',
                              suffixIcon: _commentSuggestions == null
                                  ? const CupertinoActivityIndicator()
                                  : _commentSuggestions!.isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () =>
                                              _showCommentSuggestions(context),
                                          icon: const Icon(Icons.more_horiz)),
                            ),
                            readOnly: false,
                            onSaved: (newValue) =>
                                widget.timeEntry.comment = newValue,
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
            ),
    );
  }
}
