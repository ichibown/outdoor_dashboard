import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:outdoor_dashboard/utils/app_ext.dart';
import 'package:outdoor_dashboard/utils/const.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../model/main_data_model.dart';
import '../../utils/ext.dart';

class SummaryDataCardView extends StatefulWidget {
  const SummaryDataCardView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SummaryDataCardState();
  }
}

class _SummaryDataCardState extends State<SummaryDataCardView> {
  late var gradientColors = <Color>[
    Theme.of(context).colorScheme.primary,
    Theme.of(context).colorScheme.primary,
  ];

  AxisTitles get _noTitle => const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      );
  FlBorderData get _noBorder => FlBorderData(show: false);

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
      width: 320,
      height: 270,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            data.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _dataRow(),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: data.isBar ? _barChart() : _lineChart(),
          )
        ],
      ),
    );
  }

  Widget _dataRow() {
    var titleStyle = Theme.of(context).textTheme.labelSmall;
    titleStyle =
        titleStyle?.copyWith(color: titleStyle.color?.withOpacity(0.5));
    var dataStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    var distance = data.distance < 1000
        ? '${data.distance.toInt()}km'
        : '${data.distance.toInt() ~/ 1000}km';
    var duration = data.duration < 3600
        ? '${data.duration ~/ 60}min'
        : '${data.duration ~/ 3600}:${data.duration % 3600 ~/ 60}:${data.duration % 60}';
    var pace = '${data.avgPace.toInt() ~/ 60}\'${data.avgPace.toInt() % 60}"';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.current.summaryCardItemDistance,
                style: titleStyle, textAlign: TextAlign.center),
            Text(distance, style: dataStyle, textAlign: TextAlign.center),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.current.summaryCardItemCounts,
                style: titleStyle, textAlign: TextAlign.center),
            Text(data.counts.toString(),
                style: dataStyle, textAlign: TextAlign.center),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.current.summaryCardItemDuration,
                style: titleStyle, textAlign: TextAlign.center),
            Text(duration, style: dataStyle, textAlign: TextAlign.center),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.current.summaryCardItemAvgPace,
                style: titleStyle, textAlign: TextAlign.center),
            Text(pace, style: dataStyle, textAlign: TextAlign.center),
          ],
        ),
      ],
    );
  }

  LineChart _lineChart() {
    var chartData = LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: _noTitle,
        topTitles: _noTitle,
        bottomTitles: _xAxisTitles(),
        leftTitles: _yAxisTtiles(),
      ),
      borderData: _noBorder,
      minX: 0,
      maxX: data.values.length - 1,
      minY: 0,
      maxY: data.values.maxBy((e) => e).toDouble(),
      gridData: _backgroundGridLine(),
      lineTouchData: LineTouchData(
        enabled: true,
        getTouchedSpotIndicator: _lineDotTouchIndicator,
        touchTooltipData: _lineTouchTooltip(),
      ),
      lineBarsData: [_mainLineData()],
    );
    return LineChart(chartData);
  }

  BarChart _barChart() {
    var chartData = BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: _noTitle,
        topTitles: _noTitle,
        bottomTitles: _xAxisTitles(),
        leftTitles: _yAxisTtiles(),
      ),
      borderData: _noBorder,
      minY: 0,
      maxY: data.values.maxBy((e) => e).toDouble(),
      gridData: _backgroundGridLine(),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: _barTouchTooltip(),
      ),
      barGroups: _mainBarData(),
    );
    return BarChart(chartData);
  }

  LineChartBarData _mainLineData() {
    return LineChartBarData(
      spots: data.values.indexed
          .map((e) => FlSpot(e.$1.toDouble(), e.$2.toDouble()))
          .toList(),
      isCurved: true,
      gradient: LinearGradient(colors: gradientColors),
      dotData: const FlDotData(show: false),
      barWidth: 1,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: gradientColors.map((c) => c.withOpacity(0.6)).toList(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _mainBarData() {
    return data.values.indexed
        .map((e) => BarChartGroupData(x: e.$1, barRods: [
              BarChartRodData(
                toY: e.$2,
                gradient: LinearGradient(
                    colors: gradientColors
                        .map((c) => c.withOpacity(0.75))
                        .toList()),
              )
            ]))
        .toList();
  }

  AxisTitles _xAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: 1,
        getTitlesWidget: (value, meta) {
          var date = data.dates[value.toInt()];
          var text = months[date.month - 1];
          if (data.year == YearSelectData.all) {
            text = date.month == 5 ? '${date.year}' : '';
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 6,
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  AxisTitles _yAxisTtiles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: data.values.maxBy((e) => e) / 4,
        getTitlesWidget: (value, meta) {
          var text = '${value.toInt()}';
          if (value >= 1000) {
            text = '${(value / 1000).toStringAsFixed(1)}k';
          }
          return Text(
            text,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.right,
          );
        },
      ),
    );
  }

  List<TouchedSpotIndicatorData> _lineDotTouchIndicator(
      LineChartBarData barData, List<int> indicators) {
    return indicators.map((int index) {
      var color = barData.gradient?.colors.first ?? Colors.grey;
      return TouchedSpotIndicatorData(
        FlLine(color: color, strokeWidth: 0.3),
        FlDotData(
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            color: color,
            strokeWidth: 1,
            strokeColor: color,
          ),
        ),
      );
    }).toList();
  }

  LineTouchTooltipData _lineTouchTooltip() {
    return LineTouchTooltipData(
      tooltipBgColor: Theme.of(context).colorScheme.background,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      tooltipBorder: BorderSide(
        color: Theme.of(context).dividerColor,
        width: 0.1,
      ),
      getTooltipItems: (touchedSpots) => touchedSpots
          .map((e) => LineTooltipItem(
                '${e.y.toInt()}km\n${data.dates[e.x.toInt()].yyyyMM()}',
                Theme.of(context).textTheme.bodySmall!,
              ))
          .toList(),
    );
  }

  BarTouchTooltipData _barTouchTooltip() {
    return BarTouchTooltipData(
      tooltipBgColor: Theme.of(context).colorScheme.background,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      tooltipBorder: BorderSide(
        color: Theme.of(context).dividerColor,
        width: 0.1,
      ),
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        var value = data.values[groupIndex];
        return BarTooltipItem(
          '${value.toInt()}km\n${data.dates[groupIndex].yyyyMM()}',
          Theme.of(context).textTheme.bodySmall!,
        );
      },
    );
  }

  FlGridData _backgroundGridLine() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: data.values.maxBy((e) => e) / 4,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Theme.of(context).dividerColor,
        strokeWidth: 0.3,
        dashArray: [4, 2],
      ),
    );
  }
}
