import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/local.dart';
import '../utils/ext.dart';

class MainDataModel extends ChangeNotifier {
  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  late YearSelectData _yearSelectData;
  YearSelectData get yearSelectData => _yearSelectData;

  final Map<int, SummaryCardData> _yearlySummaryCardData = {};
  SummaryCardData? yearlySummaryCardData(int year) =>
      _yearlySummaryCardData[year];

  MainDataModel(OutdoorSummary summary) {
    var activities = summary.activities;
    _updateDataModels(activities ?? []);
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void selectYear(int year) {
    if (_yearSelectData.selectedYear == year) {
      return;
    }
    _yearSelectData = _yearSelectData.copyWith(selectedYear: year);
    notifyListeners();
  }

  void _updateDataModels(List<OutdoorActivity> activities) async {
    var activitiesByYear = activities.groupBy((e) =>
        DateTime.fromMillisecondsSinceEpoch(e.startTime, isUtc: true)
            .add(Duration(milliseconds: e.timeOffset))
            .year);

    _yearSelectData = YearSelectData(
      yearlyCounts: activitiesByYear.map(
        (key, value) => MapEntry(key, value.length),
      ),
      selectedYear: YearSelectData.all,
    )..yearlyCounts[YearSelectData.all] = activities.length;

    var summaryDataByYear = activitiesByYear.map(
      (key, value) => MapEntry(key, _buildSummaryCardByYear(key, value)),
    );
    _yearlySummaryCardData.addAll(summaryDataByYear);
    var summaryDataAll =
        _buildSummaryCardAll(summaryDataByYear.values.toList());
    _yearlySummaryCardData[YearSelectData.all] = summaryDataAll;
  }

  SummaryCardData _buildSummaryCardAll(List<SummaryCardData> summaryList) {
    var accDistance = <double>[];
    var dates = <DateTime>[];
    summaryList.sort((left, right) => left.year - right.year);
    for (var i = summaryList.first.year; i <= summaryList.last.year; i++) {
      var data = summaryList.firstWhereOrNull((e) => e.year == i);
      if (data != null) {
        accDistance.addAll(data.values);
      } else {
        accDistance.addAll(List.filled(12, 0));
      }
      dates.addAll(List.generate(12, (index) => DateTime(i, index + 1)));
    }
    for (var i = 0; i < accDistance.length - 1; i++) {
      accDistance[i + 1] += accDistance[i];
    }
    return SummaryCardData(
      year: YearSelectData.all,
      counts: summaryList.sumBy((e) => e.counts).toInt(),
      distance: summaryList.sumBy((e) => e.distance).toDouble(),
      duration: summaryList.sumBy((e) => e.duration).toInt(),
      avgPace: summaryList.sumBy((e) => e.avgPace * e.counts) /
          summaryList.sumBy((e) => e.counts).toInt(),
      values: accDistance,
      dates: dates,
      isBar: false,
    );
  }

  SummaryCardData _buildSummaryCardByYear(
      int year, List<OutdoorActivity> activities) {
    activities.sort((left, right) =>
        (left.startTime + left.timeOffset) -
        (right.startTime + right.timeOffset));

    var accDistance = activities
        .groupBy((e) =>
            DateTime.fromMillisecondsSinceEpoch(e.startTime, isUtc: true)
                .add(Duration(milliseconds: e.timeOffset))
                .month)
        .map((k, v) =>
            MapEntry(k, v.sumBy((e) => (e.totalDistance) / 1000).toDouble()))
        .entries
        .toList();
    for (var i = 1; i <= 12; i++) {
      if (!accDistance.any((e) => e.key == i)) {
        accDistance.add(MapEntry(i, 0));
      }
    }
    accDistance.sort((left, right) => left.key - right.key);
    return SummaryCardData(
      year: year,
      counts: activities.length,
      distance: activities.sumBy((e) => e.totalDistance).toDouble(),
      duration: activities.sumBy((e) => e.elapsedTime).toInt(),
      avgPace: activities.sumBy((e) => e.avgPace) / activities.length,
      values: accDistance.map((e) => e.value).toList(),
      dates: List.generate(12, (index) => DateTime(year, index + 1)),
      isBar: true,
    );
  }
}

class YearSelectData {
  static const all = 9999;

  Map<int, int> yearlyCounts;
  int selectedYear;

  YearSelectData({
    required this.yearlyCounts,
    required this.selectedYear,
  });

  YearSelectData copyWith({
    Map<int, int>? yearlyCounts,
    int? selectedYear,
  }) {
    return YearSelectData(
      yearlyCounts: yearlyCounts ?? this.yearlyCounts,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

class SummaryCardData {
  int year;

  /// digit data.
  int counts;
  double distance;
  int duration;
  double avgPace;

  /// chart data.
  List<double> values;
  List<DateTime> dates;

  bool isBar;

  SummaryCardData({
    required this.year,
    required this.counts,
    required this.distance,
    required this.duration,
    required this.avgPace,
    required this.values,
    required this.dates,
    this.isBar = false,
  });
}
