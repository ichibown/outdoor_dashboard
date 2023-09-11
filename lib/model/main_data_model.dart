import 'package:flutter/widgets.dart';

import '../data/local.dart';

class MainDataModel extends ChangeNotifier {
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  late YearSelectData _yearSelectData;
  YearSelectData get yearSelectData => _yearSelectData;

  final Map<int, Map<int, List<OutdoorActivity>?>> _activitiesByMonth = {};

  MainDataModel(OutdoorSummary summary) {
    var activities = summary.activities;
    activities?.forEach((activity) {
      var date = DateTime.fromMillisecondsSinceEpoch(activity.startTime ?? 0,
              isUtc: true)
          .add(Duration(milliseconds: activity.timeOffset ?? 0));
      var year = date.year;
      var month = date.month;
      if (_activitiesByMonth[year] == null) {
        _activitiesByMonth[year] = {};
      }
      if (_activitiesByMonth[year]?[month] == null) {
        _activitiesByMonth[year]?[month] = [];
      }
      _activitiesByMonth[year]?[month]?.add(activity);
    });
    var yearlyCount = {
      YearSelectData.all: activities?.length ?? 0,
    }..addAll(
        _activitiesByMonth.map(
          (key, value) => MapEntry(
              key,
              value.values
                  .map((e) => e?.length ?? 0)
                  .reduce((value, element) => value + element)),
        ),
      );
    _yearSelectData = YearSelectData(
      yearlyCounts: yearlyCount,
      selectedYear: YearSelectData.all,
    );
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void selectYear(int year) {
    if (!_yearSelectData.yearlyCounts.containsKey(year)) {
      return;
    }
    _yearSelectData = YearSelectData(
      yearlyCounts: _yearSelectData.yearlyCounts,
      selectedYear: year,
    );
    notifyListeners();
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
}
