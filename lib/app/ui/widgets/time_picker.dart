import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final int hours;
  final int minutes;
  final Function(DateTime) onTimeChanged;

  const TimePicker({
    required this.hours,
    required this.minutes,
    required this.onTimeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const minuteInterval = 5;
    final roundedMinutes = minutes - minutes % minuteInterval;
    return Container(
      height: 300,
      color: Theme.of(context).canvasColor,
      child: CupertinoDatePicker(
        initialDateTime: DateTime(
          2000,
          1,
          1,
          hours,
          roundedMinutes,
        ),
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        onDateTimeChanged: onTimeChanged,
        minuteInterval: minuteInterval,
      ),
    );
  }
}
