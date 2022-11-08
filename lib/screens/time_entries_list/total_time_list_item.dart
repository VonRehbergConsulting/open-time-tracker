import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/helpers/duration_formatter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TotalTimeListItem extends StatelessWidget {
  final Duration timeSpent;
  final Duration workingHours = const Duration(hours: 8);
  const TotalTimeListItem(this.timeSpent, {super.key});

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

  @override
  Widget build(BuildContext context) {
    final percent = timeSpent.inMinutes / 480;
    final percentText = '${(percent * 100).toStringAsFixed(0)}%';
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
                  animation: true,
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
                      DurationFormatter.shortWatch(timeSpent),
                    ),
                    _createIconText(
                      Icons.timer_outlined,
                      DurationFormatter.shortWatch(timeLeft),
                    ),
                    _createIconText(
                      Icons.calendar_month_outlined,
                      DurationFormatter.shortWatch(workingHours),
                    ),
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: const Text(
                    //     'Change working hours',
                    //     style: TextStyle(color: Colors.black54),
                    //   ),
                    // ),
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
