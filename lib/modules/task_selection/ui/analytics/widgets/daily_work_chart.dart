import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/extensions/duration.dart';

import '../../../../../app/ui/widgets/configured_bar_chart.dart';
import '../../../../../app/ui/widgets/chart_text_style.dart';

class DailyWorkChartData {
  final Duration monday;
  final Duration tuesday;
  final Duration wednesday;
  final Duration thursday;
  final Duration friday;
  final Duration saturday;
  final Duration sunday;

  DailyWorkChartData({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });
}

class DailyWorkChart extends StatelessWidget {
  final DailyWorkChartData data;
  const DailyWorkChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final totalTime = (data.monday +
            data.tuesday +
            data.wednesday +
            data.thursday +
            data.friday +
            data.saturday +
            data.sunday)
        .withLetters();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConfiguredBarChart(
          data: [
            _hours(data.monday),
            _hours(data.tuesday),
            _hours(data.wednesday),
            _hours(data.thursday),
            _hours(data.friday),
            _hours(data.saturday),
            _hours(data.sunday),
          ],
        ),
        SizedBox(height: 8.0),
        Text(
          '${AppLocalizations.of(context).generic_total}: $totalTime',
          style: ChartTextstyle(),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  double _hours(Duration duration) {
    return duration.inMinutes / 60;
  }
}
