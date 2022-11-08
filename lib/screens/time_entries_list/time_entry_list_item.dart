import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/widgets/list_item.dart';

import '/helpers/duration_formatter.dart';

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
    final trailing = DurationFormatter.withLetters(hours);
    return ListItem(
      title: workPackageSubject,
      subtitle: projectTitle,
      comment: comment,
      trailing: trailing,
      action: action,
    );
  }
}
