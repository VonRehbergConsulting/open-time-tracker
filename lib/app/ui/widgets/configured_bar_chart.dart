import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/chart_text_style.dart';

class ConfiguredBarChartItem {
  final String title;
  final double value;

  ConfiguredBarChartItem({
    required this.title,
    required this.value,
  });
}

class ConfiguredBarChart extends StatelessWidget {
  final List<ConfiguredBarChartItem> data;
  const ConfiguredBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: _BarChart(data),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<ConfiguredBarChartItem> data;
  const _BarChart(this.data);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data.fold(0.0, (current, second) => max(current, second.value)) + 1,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.toStringAsFixed(
                  rod.toY.truncateToDouble() == rod.toY ? 0 : 1),
              const ChartTextStyle(),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = ChartTextStyle();
    String text = data[value.toInt()].title;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Color.fromARGB(255, 45, 102, 201),
          Color.fromRGBO(40, 185, 185, 1),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  BarChartGroupData _bar(
    int x,
    double y,
  ) =>
      BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: [0],
      );

  List<BarChartGroupData> get barGroups {
    return data
        .asMap()
        .entries
        .map((entry) => _bar(entry.key, entry.value.value))
        .toList();
  }
}
