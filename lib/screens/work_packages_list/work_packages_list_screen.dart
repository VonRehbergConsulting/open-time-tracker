import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/screens/work_packages_list/work_package_list_item.dart';
import 'package:provider/provider.dart';

import '/models/work_packages_provider.dart';

class WorkPackagesListScreen extends StatelessWidget {
  static const routeName = '/work-packages';

  const WorkPackagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<WorkPackagesProvider>(context, listen: false).reload();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Consumer<WorkPackagesProvider>(
          builder: (context, workPackages, child) {
            return ListView.builder(
              itemCount: workPackages.items.length,
              itemBuilder: ((context, index) {
                final workPackage = workPackages.items[index];
                return WorkPackageListItem(
                  subject: workPackage.subject,
                  projectTitle: workPackage.projectTitle,
                  status: workPackage.status,
                  priority: workPackage.priority,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
