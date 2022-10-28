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
  void _submit(BuildContext context) async {
    final userId = Provider.of<UserDataProvider>(context, listen: false).userId;
    if (userId == null) {
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.timeEntry.workPackageSubject,
                      decoration: const InputDecoration(labelText: 'Task'),
                      readOnly: true,
                    ),
                    TextFormField(
                      initialValue: widget.timeEntry.projectTitle,
                      decoration: const InputDecoration(labelText: 'Project'),
                      readOnly: true,
                    ),
                    TextFormField(
                      initialValue:
                          DurationFormatter.longWatch(widget.timeEntry.hours),
                      decoration:
                          const InputDecoration(labelText: 'Time spent'),
                      readOnly: true,
                    ),
                    TextFormField(
                      initialValue: widget.timeEntry.comment,
                      decoration: const InputDecoration(labelText: 'Comment'),
                      readOnly: false,
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
