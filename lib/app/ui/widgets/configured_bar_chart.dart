import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:open_project_time_tracker/app/ui/widgets/chart_text_style.dart';

class _BarChart extends StatelessWidget {
  final List<double> data;
  const _BarChart(this.data);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: data.reduce((first, second) => max(first, second)) + 1,
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
              ChartTextstyle(),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = ChartTextstyle();
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        text = '';
        break;
    }
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
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
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
        .map((entry) => _bar(entry.key, entry.value))
        .toList();
  }
}

class ConfiguredBarChart extends StatelessWidget {
  final List<double> data;
  const ConfiguredBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: _BarChart(data),
    );
  }
}
