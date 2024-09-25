import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../app/ui/widgets/configured_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/extensions/duration.dart';

class TimeEntryListItem extends StatelessWidget {
  // Properties

  final String workPackageSubject;
  final String projectTitle;
  final Duration hours;
  final String? comment;
  final Function()? action;
  final Future<bool> Function()? dismissAction;

  // Init
  const TimeEntryListItem({
    super.key,
    required this.workPackageSubject,
    required this.projectTitle,
    required this.hours,
    required this.comment,
    this.action,
    this.dismissAction,
  });

  Future<bool> _showCloseDialog(BuildContext context) async {
    var consent = false;
    await showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).generic_warning),
        content: Text(AppLocalizations.of(context).generic_deletion_warning),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).generic_no),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              consent = true;
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).generic_yes),
          ),
        ],
      ),
    );
    return consent && dismissAction != null ? await dismissAction!() : false;
  }

  // Lifecycle

  @override
  Widget build(BuildContext context) {
    final trailing = hours.withLetters();
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) => _showCloseDialog(context),
      direction: DismissDirection.endToStart,
      background: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.delete,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: action,
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
                SizedBox(
                    height: comment != null && comment!.isNotEmpty ? 6 : 0),
                if (comment != null && comment!.isNotEmpty) Text(comment!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
