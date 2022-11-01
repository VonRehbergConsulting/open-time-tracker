import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/time_entries_provider.dart';
import '/models/time_entry.dart';
import '/models/user_data_provider.dart';
import '/services/app_router.dart';
import '/services/duration_formatter.dart';

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

  var _isLoading = false;

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
      AppRouter.routeToTimeEntriesList(context, widget);
    } catch (error) {
      print('Error while creating time entry');
    }
  }

  void _showTimePicker() {
    final hours = widget.timeEntry.hours.inHours;
    final minutes = widget.timeEntry.hours.inMinutes.remainder(60);
    showCupertinoModalPopup(
      context: context,
      builder: ((context) => Container(
            height: 300,
            color: Theme.of(context).canvasColor,
            child: CupertinoDatePicker(
              initialDateTime: DateTime(
                2000,
                1,
                1,
                hours,
                minutes,
              ),
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              onDateTimeChanged: ((value) {
                setState(() {
                  widget.timeEntry.hours = Duration(
                    hours: value.hour,
                    minutes: value.minute,
                  );
                });
              }),
            ),
          )),
    );
  }

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    _timeFieldController.text =
        DurationFormatter.shortWatch(widget.timeEntry.hours);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
                            initialValue: widget.timeEntry.comment,
                            decoration:
                                const InputDecoration(labelText: 'Comment'),
                            readOnly: false,
                            onSaved: (newValue) =>
                                widget.timeEntry.comment = newValue,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _submit(context),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
