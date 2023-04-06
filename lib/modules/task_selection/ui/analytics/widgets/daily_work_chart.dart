import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_project_time_tracker/app/ui/widgets/configured_cart.dart';
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
    return ConfiguredCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 12.0),
            ConfiguredBarChart(
              data: [
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_monday_short,
                  value: _hours(data.monday),
                ),
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_tuesday_short,
                  value: _hours(data.tuesday),
                ),
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_wednesday_short,
                  value: _hours(data.wednesday),
                ),
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_thursday_short,
                  value: _hours(data.thursday),
                ),
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_friday_short,
                  value: _hours(data.friday),
                ),
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_saturday_short,
                  value: _hours(data.saturday),
                ),
                ConfiguredBarChartItem(
                  title: AppLocalizations.of(context).generic_sunday_short,
                  value: _hours(data.sunday),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              '${AppLocalizations.of(context).generic_total}: $totalTime',
              style: ChartTextstyle(),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  double _hours(Duration duration) {
    return duration.inMinutes / 60;
  }
}
