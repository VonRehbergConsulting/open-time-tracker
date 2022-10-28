import 'package:flutter/material.dart';

import '/services/duration_formatter.dart';

class TimeEntryListItem extends StatelessWidget {
  // Properties

  final String workPackageSubject;
  final String projectTitle;
  final Duration hours;
  final String comment;
  final Function action;

  // Init
  const TimeEntryListItem({
    super.key,
    required this.workPackageSubject,
    required this.projectTitle,
    required this.hours,
    required this.comment,
    required this.action,
  });

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action(),
      child: Card(
        margin: const EdgeInsets.symmetric(
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
            trailing: Text(DurationFormatter.longWatch(hours)),
          ),
        ),
      ),
    );
  }
}
