import 'package:flutter/material.dart';
import '../../../../../app/ui/widgets/configured_pie_chart.dart';

class ProjectChartData {
  final String title;
  final Duration duration;

  ProjectChartData({
    required this.title,
    required this.duration,
  });
}

class ProjectsChart extends StatelessWidget {
  final colors = [
    Color(0xFF265cb9),
    Color(0xFF007bd1),
    Color(0xFF0097d9),
    Color(0xFF00b1d5),
    Color(0xFF00c8c8),
    Color(0xFF2dddb6),
    Color(0xFF8df0a8),
    Color(0xFFd2ffa1),
  ];

  final List<ProjectChartData> items;
  ProjectsChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConfiguredPieChart(
          items: items.asMap().entries.map((entry) {
            final hours = entry.value.duration.inMinutes / 60;
            return ConfiguredPieChardItem(
              title: entry.value.title,
              value: hours / 60,
              text: hours
                  .toStringAsFixed(hours.truncateToDouble() == hours ? 0 : 1),
              color: colors[entry.key % colors.length],
            );
          }).toList(),
        ),
      ),
    );
  }
}
