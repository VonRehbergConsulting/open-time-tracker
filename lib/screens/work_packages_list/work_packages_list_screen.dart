import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/time_entry.dart';
import '/screens/work_packages_list/work_package_list_item.dart';
import '/helpers/app_router.dart';
import '/models/work_packages_provider.dart';
import '/widgets/activity_indicator.dart';

class WorkPackagesListScreen extends StatefulWidget {
  const WorkPackagesListScreen({super.key});

  @override
  State<WorkPackagesListScreen> createState() => _WorkPackagesListScreenState();
}

class _WorkPackagesListScreenState extends State<WorkPackagesListScreen> {
  // Properties

  late Future _listFuture;

  // Lifecycle

  @override
  void initState() {
    super.initState();
    _listFuture =
        Provider.of<WorkPackagesProvider>(context, listen: false).reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: _listFuture,
          builder: ((context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: ActivityIndicator())
                : Consumer<WorkPackagesProvider>(
                    builder: (context, workPackages, child) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await Provider.of<WorkPackagesProvider>(context,
                                  listen: false)
                              .reload();
                          setState(() {});
                        },
                        child: ListView.builder(
                          itemCount: workPackages.items.length,
                          itemBuilder: ((context, index) {
                            final workPackage = workPackages.items[index];
                            return WorkPackageListItem(
                              subject: workPackage.subject,
                              projectTitle: workPackage.projectTitle,
                              status: workPackage.status,
                              priority: workPackage.priority,
                              action: () => AppRouter.routeToTimer(
                                  context,
                                  TimeEntry.forWorkPackage(workPackage),
                                  widget),
                            );
                          }),
                        ),
                      );
                    },
                  );
          }),
        ),
      ),
    );
  }
}
