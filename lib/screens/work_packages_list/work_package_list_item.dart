import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/widgets/list_item.dart';

class WorkPackageListItem extends StatelessWidget {
  // Properties

  final String subject;
  final String projectTitle;
  final String priority;
  final String status;
  final Function action;

  // Init
  const WorkPackageListItem({
    super.key,
    required this.subject,
    required this.projectTitle,
    required this.priority,
    required this.status,
    required this.action,
  });

  // Private methods

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    return ListItem(
      title: subject,
      subtitle: projectTitle,
      comment: priority,
      trailing: status,
      action: action,
    );
  }
}
