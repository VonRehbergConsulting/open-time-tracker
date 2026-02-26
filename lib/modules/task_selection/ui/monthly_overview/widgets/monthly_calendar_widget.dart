import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_project_time_tracker/l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_card.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';

// UI constants for calendar layout
const double _kDayCellHeight = 48.0;
const double _kWeekColumnWidth = 50.0;
const double _kCellMargin = 2.0;

class MonthlyCalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final Map<int, Duration> dailyHours;
  final Map<int, Duration> weeklyHours;
  final Function(int year, int month)? onMonthChanged;

  const MonthlyCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.dailyHours,
    required this.weeklyHours,
    this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;
    final monthName = DateFormat.yMMMM().format(DateTime(year, month));

    return ConfiguredCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Month navigation header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final prevMonth = month == 1 ? 12 : month - 1;
                    final prevYear = month == 1 ? year - 1 : year;
                    onMonthChanged?.call(prevYear, prevMonth);
                  },
                ),
                Text(
                  monthName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final now = DateTime.now();
                    // Don't allow navigation to future months
                    if (year < now.year || (year == now.year && month < now.month)) {
                      final nextMonth = month == 12 ? 1 : month + 1;
                      final nextYear = month == 12 ? year + 1 : year;
                      onMonthChanged?.call(nextYear, nextMonth);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday headers
            Row(
              children: [
                for (int i = 1; i <= 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _getWeekdayName(i, context),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                // Week total column header
                SizedBox(
                  width: _kWeekColumnWidth,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).monthly_overview_week,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Calendar grid
            ..._buildCalendarRows(firstWeekday, daysInMonth),

            const SizedBox(height: 16),

            // Monthly total
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(38, 92, 185, 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).monthly_overview_total,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(38, 92, 185, 1),
                    ),
                  ),
                  Text(
                    _getTotalHours().withLetters(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(38, 92, 185, 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int weekday, BuildContext context) {
    switch (weekday) {
      case 1: return AppLocalizations.of(context).weekday_monday;
      case 2: return AppLocalizations.of(context).weekday_tuesday;
      case 3: return AppLocalizations.of(context).weekday_wednesday;
      case 4: return AppLocalizations.of(context).weekday_thursday;
      case 5: return AppLocalizations.of(context).weekday_friday;
      case 6: return AppLocalizations.of(context).weekday_saturday;
      case 7: return AppLocalizations.of(context).weekday_sunday;
      default: return '';
    }
  }

  List<Widget> _buildCalendarRows(int firstWeekday, int daysInMonth) {
    final List<Widget> rows = [];
    int currentDay = 1;
    int weekRow = 0;

    // Calculate total number of weeks needed
    final totalCells = firstWeekday - 1 + daysInMonth;
    final totalWeeks = (totalCells / 7).ceil();

    for (int week = 0; week < totalWeeks; week++) {
      final List<Widget> dayCells = [];

      for (int weekday = 1; weekday <= 7; weekday++) {
        if ((week == 0 && weekday < firstWeekday) || currentDay > daysInMonth) {
          // Empty cell for days outside the month
          dayCells.add(
            Expanded(
              child: Container(
                height: _kDayCellHeight,
                margin: const EdgeInsets.all(_kCellMargin),
              ),
            ),
          );
        } else {
          // Day cell with hours
          final hours = dailyHours[currentDay] ?? Duration.zero;
          dayCells.add(
            Expanded(
              child: _buildDayCell(currentDay, hours),
            ),
          );
          currentDay++;
        }
      }

      // Add weekly total for this row
      final weekTotal = weeklyHours[weekRow] ?? Duration.zero;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              ...dayCells,
              SizedBox(
                width: _kWeekColumnWidth,
                child: Center(
                  child: Text(
                    weekTotal.inMinutes > 0
                        ? weekTotal.withLetters()
                        : '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: weekTotal.inMinutes > 0
                          ? const Color.fromRGBO(38, 92, 185, 1)
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      weekRow++;
    }

    return rows;
  }

  Widget _buildDayCell(int day, Duration hours) {
    final hasHours = hours.inMinutes > 0;
    final now = DateTime.now();
    final isToday = day == now.day && month == now.month && year == now.year;

    // For booked days (not today), use gradient border
    if (hasHours && !isToday) {
      return Container(
        height: _kDayCellHeight,
        margin: const EdgeInsets.all(_kCellMargin),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 45, 102, 201),
              Color.fromRGBO(40, 185, 185, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildDayCellContent(day, hours, isToday),
        ),
      );
    }

    // For today or empty days, use regular border
    return Container(
      height: _kDayCellHeight,
      margin: const EdgeInsets.all(_kCellMargin),
      decoration: BoxDecoration(
        color: isToday
            ? const Color.fromRGBO(38, 92, 185, 0.15)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? const Color.fromRGBO(38, 92, 185, 1)
              : Colors.grey.shade200,
          width: isToday ? 2 : 1,
        ),
      ),
      child: _buildDayCellContent(day, hours, isToday),
    );
  }

  Widget _buildDayCellContent(int day, Duration hours, bool isToday) {
    final hasHours = hours.inMinutes > 0;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          day.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: isToday ? const Color.fromRGBO(38, 92, 185, 1) : Colors.grey.shade800,
          ),
        ),
        if (hasHours) ...[
          const SizedBox(height: 2),
          Text(
            '${(hours.inMinutes / 60).toStringAsFixed(1)}h',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Duration _getTotalHours() {
    return dailyHours.values.fold(Duration.zero, (sum, duration) => sum + duration);
  }
}
