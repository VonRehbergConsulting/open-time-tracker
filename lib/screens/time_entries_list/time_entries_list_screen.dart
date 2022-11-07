import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/models/network_provider.dart';
import 'package:provider/provider.dart';

import '/services/duration_formatter.dart';
import '/models/time_entries_provider.dart';
import '/screens/time_entries_list/time_entry_list_item.dart';
import '/screens/time_entries_list/total_time_list_item.dart';
import '/services/app_router.dart';
import '/widgets/activity_indicator.dart';

class TimeEntriesListScreen extends StatefulWidget {
  const TimeEntriesListScreen({super.key});

  @override
  State<TimeEntriesListScreen> createState() => _TimeEntriesListScreenState();
}

class _TimeEntriesListScreenState extends State<TimeEntriesListScreen> {
  // Properties

  late Future _listFuture;

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _listFuture =
        Provider.of<TimeEntriesProvider>(context, listen: false).reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent work'),
        leading: IconButton(
            onPressed: (() =>
                Provider.of<NetworkProvider>(context, listen: false)
                    .unauthorize()),
            icon: const Icon(Icons.exit_to_app_sharp)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: _listFuture,
          builder: ((context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: ActivityIndicator())
                : Consumer<TimeEntriesProvider>(
                    builder: (context, timeEntries, child) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await Provider.of<TimeEntriesProvider>(context,
                                  listen: false)
                              .reload();
                          setState(() {});
                        },
                        child: ListView.builder(
                          itemCount: timeEntries.items.length + 1,
                          itemBuilder: ((context, index) {
                            if (index == 0) {
                              return TotalTimeListItem(
                                  'Time spent today: ${DurationFormatter.shortWatch(timeEntries.totalDuration)}');
                            }
                            final timeEntry = timeEntries.items[index - 1];
                            return TimeEntryListItem(
                              workPackageSubject: timeEntry.workPackageSubject,
                              projectTitle: timeEntry.projectTitle,
                              hours: timeEntry.hours,
                              comment: timeEntry.comment ?? '',
                              action: () => AppRouter.routeToTimer(
                                context,
                                timeEntry,
                                widget,
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => AppRouter.routeToWorkPackagesList(context),
      ),
    );
  }
}
