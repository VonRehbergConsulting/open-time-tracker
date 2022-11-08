import 'package:flutter/material.dart';

import '/extensions/duration.dart';
import '/widgets/list_item.dart';

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
    final trailing = hours.withLetters();
    return ListItem(
      title: workPackageSubject,
      subtitle: projectTitle,
      comment: comment,
      trailing: trailing,
      action: action,
    );
  }
}
