import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/time_entries_provider.dart';
import '/screens/time_entries_list/time_entry_list_item.dart';
import '/services/routes_factory.dart';

class TimeEntriesListScreen extends StatelessWidget {
  const TimeEntriesListScreen({super.key});

  void _addButtonAction(BuildContext context) {
    Navigator.of(context).push(RoutesFactory.workPackagesList);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<TimeEntriesProvider>(context, listen: false).reload();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent work'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Consumer<TimeEntriesProvider>(
          builder: (context, timeEntries, child) {
            return ListView.builder(
              itemCount: timeEntries.items.length,
              itemBuilder: ((context, index) {
                final timeEntry = timeEntries.items[index];
                return TimeEntryListItem(
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
        onPressed: () => _addButtonAction(context),
      ),
    );
  }
}
