import 'package:flutter/material.dart';

class WorkPackageListItem extends StatelessWidget {
  // Properties

  final String subject;
  final String projectTitle;
  final String priority;
  final String status;

  // Init
  const WorkPackageListItem({
    super.key,
    required this.subject,
    required this.projectTitle,
    required this.priority,
    required this.status,
  });

  // Private methods

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 15,
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          title: Text(subject),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(priority),
              Text(projectTitle),
            ],
          ),
          trailing: Text(status),
        ),
      ),
    );
  }
}
