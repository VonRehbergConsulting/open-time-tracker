import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';

class DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  const DateNavigator({
    super.key,
    required this.selectedDate,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return AppLocalizations.of(context).generic_today;
    } else if (selectedDay == yesterday) {
      return AppLocalizations.of(context).generic_yesterday;
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final isTodayOrFuture =
        selectedDay.isAtSameMomentAs(today) || selectedDay.isAfter(today);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousDay,
            icon: const Icon(Icons.chevron_left),
            iconSize: 32,
          ),
          Expanded(
            child: Text(
              _formatDate(context, selectedDate),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: isTodayOrFuture ? null : onNextDay,
            icon: const Icon(Icons.chevron_right),
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}
