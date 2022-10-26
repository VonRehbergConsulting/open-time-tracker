import 'package:flutter/material.dart';

class TimeEntryItem extends StatelessWidget {
  // Properties

  final String workPackageSubject;
  final String projectTitle;
  final Duration hours;
  final String comment;

  // Init
  const TimeEntryItem({
    super.key,
    required this.workPackageSubject,
    required this.projectTitle,
    required this.hours,
    required this.comment,
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
          title: Text(workPackageSubject),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(projectTitle),
              Text(comment),
            ],
          ),
          trailing: Text(hours.toString()),
        ),
      ),
    );
  }
}
