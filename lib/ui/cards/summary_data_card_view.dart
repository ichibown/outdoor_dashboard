import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:outdoor_dashboard/utils/app_ext.dart';
import 'package:outdoor_dashboard/utils/ext.dart';
import 'package:provider/provider.dart';

import '../../model/main_data_model.dart';

class SummaryDataCardView extends StatefulWidget {
  const SummaryDataCardView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SummaryDataCardState();
  }
}

class _SummaryDataCardState extends State<SummaryDataCardView> {
  final List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  late SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    var selectedYear = context
        .select<MainDataModel, YearSelectData>((value) => value.yearSelectData)
        .selectedYear;
    var summary =
        context.read<MainDataModel>().yearlySummaryCardData(selectedYear);
    if (summary == null) {
      return const Placeholder();
    }
    data = summary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              // todo: data text.
            ],
          ),
          SizedBox(
            width: 400,
            height: 200,
            child: LineChart(_lineData(context)),
          )
        ],
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    var style = Theme.of(context).textTheme.bodySmall;
    Widget text;
    if (value == 0) {
      text = Text(data.startDate.yyyyMM(), style: style);
    } else if (value == data.accDistance.length - 1) {
      text = Text(data.endDate.yyyyMM(), style: style);
    } else {
      text = const Text('');
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 12,
      child: text,
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    var style = Theme.of(context).textTheme.bodySmall;
    var text = '${value.toInt()}';
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
    }
    return Text(text, style: style, textAlign: TextAlign.right);
  }

  LineChartData _lineData(BuildContext context) {
    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 12,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 500,
            getTitlesWidget: _leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: data.accDistance.length - 1,
      minY: data.accDistance.minBy((e) => e).toDouble(),
      maxY: data.accDistance.maxBy((e) => e).toDouble(),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          spots: data.accDistance.indexed
              .map((e) => FlSpot(e.$1.toDouble(), e.$2.toDouble()))
              .toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          dotData: const FlDotData(show: false),
          barWidth: 1,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
