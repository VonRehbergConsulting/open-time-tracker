import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/models/time_entries_provider.dart';
import 'package:open_project_time_tracker/screens/time_entries_list/work_package_item.dart';
import 'package:provider/provider.dart';

class TimeEntriesListScreen extends StatelessWidget {
  const TimeEntriesListScreen({super.key});

  void _addButtonAction() {
    //
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TimeEntriesProvider>(context, listen: false).reload();
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent work'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Consumer<TimeEntriesProvider>(
          builder: (context, timeEntries, child) {
            return ListView.builder(
              itemCount: timeEntries.items.length,
              itemBuilder: ((context, index) {
                final timeEntry = timeEntries.items[index];
                return TimeEntryItem(
                  workPackageSubject: timeEntry.workPackageSubject,
                  projectTitle: timeEntry.projectTitle,
                  hours: timeEntry.hours,
                  comment: timeEntry.comment ?? '',
                );
              }),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addButtonAction(),
      ),
    );
  }
}
