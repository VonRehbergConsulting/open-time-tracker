import 'package:flutter/material.dart';

import '../../../../../app/ui/widgets/configured_card.dart';
import '/extensions/duration.dart';

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
      child: ConfiguredCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workPackageSubject,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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
              SizedBox(height: comment != null && comment!.isNotEmpty ? 6 : 0),
              if (comment != null && comment!.isNotEmpty) Text(comment!),
            ],
          ),
        ),
      ),
    );
  }
}
