import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

/// User decision when trying to switch instances while a timer is
/// running on the currently active one.
enum TimerSwitchDecision {
  /// Route to the summary page and save the time entry, then switch.
  save,

  /// Discard the running timer (reset state) and switch immediately.
  discard,

  /// Abort the switch.
  cancel,
}

/// Modal alert that asks the user how to resolve a running timer
/// before an instance switch can proceed.
class TimerSwitchPrompt {
  const TimerSwitchPrompt._();

  static Future<TimerSwitchDecision?> show({required BuildContext context}) {
    final l10n = AppLocalizations.of(context);
    return showDialog<TimerSwitchDecision>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.instance_switch_timer_title),
          content: Text(l10n.instance_switch_timer_description),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(TimerSwitchDecision.cancel),
              child: Text(l10n.instance_switch_timer_cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(TimerSwitchDecision.discard),
              child: Text(l10n.instance_switch_timer_discard),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(TimerSwitchDecision.save),
              child: Text(l10n.instance_switch_timer_save),
            ),
          ],
        );
      },
    );
  }
}
