import 'package:flutter/material.dart';

import '/extensions/duration.dart';
import '/widgets/list_item.dart';

class TimeEntryListItem extends StatelessWidget {
  // Properties

  final String workPackageSubject;
  final String projectTitle;
  final Duration hours;
  final String? comment;
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
    return GestureDetector(
      onTap: () => action(),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workPackageSubject,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    trailing,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                projectTitle,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: comment != null ? 6 : 0),
              if (comment != null) Text(comment!),
            ],
          ),
        ),
      ),
    );
  }
}
