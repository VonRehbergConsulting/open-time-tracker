import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/widgets/time_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '/extensions/duration.dart';
import '/models/settings_provider.dart';

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
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontFeatures: [
              FontFeature.tabularFigures(),
            ],
          ),
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
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularPercentIndicator(
                  radius: 50,
                  animation: false,
                  animationDuration: 1000,
                  lineWidth: 15.0,
                  percent: min(percent, 1.0),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Theme.of(context).primaryColor,
                  center: Text(
                    percentText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 20.0,
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
                      child: const Text(
                        'Change working hours',
                        style: TextStyle(color: Colors.black54),
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
