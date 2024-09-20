import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/time_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../app/ui/widgets/configured_card.dart';
import '/extensions/duration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TotalTimeListItem extends StatelessWidget {
  final Duration workingHours;
  final Duration timeSpent;
  final Function(DateTime) onWorkingHoursChange;

  const TotalTimeListItem(
    this.workingHours,
    this.timeSpent,
    this.onWorkingHoursChange, {
    super.key,
  });

  Widget _createIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
              fontSize: 18,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ],
              color: Colors.white),
        ),
      ],
    );
  }

  void _showTimePicker(
    BuildContext passedContext,
    Duration initialValue,
  ) {
    final hours = initialValue.inHours;
    final minutes = initialValue.inMinutes.remainder(60);
    showCupertinoModalPopup(
      context: passedContext,
      builder: ((context) => TimePicker(
            hours: hours,
            minutes: minutes,
            onTimeChanged: onWorkingHoursChange,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = timeSpent.inMinutes / workingHours.inMinutes;
    final percentText =
        percent > 1 ? '>100%' : '${(percent * 100).toStringAsFixed(0)}%';
    var timeLeft = workingHours - timeSpent;
    if (timeLeft.inSeconds < 0) {
      timeLeft = const Duration();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ConfiguredCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color.fromRGBO(33, 147, 147, 1),
                Theme.of(context).primaryColor,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 16.0,
          ),
          child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularPercentIndicator(
                  radius: 50,
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 500,
                  lineWidth: 15.0,
                  percent: min(percent, 1.0),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white60,
                  center: Text(
                    percentText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _createIconText(
                      Icons.check_outlined,
                      timeSpent.shortWatch(),
                    ),
                    _createIconText(
                      Icons.timer_outlined,
                      timeLeft.shortWatch(),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showTimePicker(context, workingHours);
                      },
                      child: Text(
                        AppLocalizations.of(context)
                            .time_entries_list_change_working_hours,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
