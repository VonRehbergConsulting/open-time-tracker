import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ConfiguredPieChardItem {
  final String title;
  final double value;
  final String text;
  final Color color;

  ConfiguredPieChardItem({
    required this.title,
    required this.value,
    required this.text,
    required this.color,
  });
}

class ConfiguredPieChart extends StatelessWidget {
  final List<ConfiguredPieChardItem> items;

  const ConfiguredPieChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: _showingSections(),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ..._indicators(),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections() {
    final fontSize = 16.0;
    final radius = 50.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    return items
        .map(
          (item) => PieChartSectionData(
            color: item.color,
            value: item.value,
            title: item.text,
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          ),
        )
        .toList();
  }

  List<Widget> _indicators() {
    List<Widget> result = [];
    items.forEach((item) {
      result.add(
        Indicator(
          color: item.color,
          text: item.title,
          isSquare: true,
        ),
      );
    });
    return result;
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
