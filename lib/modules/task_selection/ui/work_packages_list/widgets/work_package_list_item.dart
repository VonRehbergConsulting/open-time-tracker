import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/list_item.dart';

class WorkPackageListItem extends StatelessWidget {
  // Properties

  final String subject;
  final String projectTitle;
  final String priority;
  final String status;
  final Function()? action;
  final Widget? commentTrailing;

  // Init
  const WorkPackageListItem({
    super.key,
    required this.subject,
    required this.projectTitle,
    required this.priority,
    required this.status,
    this.action,
    this.commentTrailing,
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
      commentTrailing: commentTrailing,
    );
  }
}
