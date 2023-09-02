import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../utils/utils.dart';
import '../utils/app_const.dart';
import '../data/local.dart';

/// Model to handle polylines on map.
class MapLinesModel extends ChangeNotifier {
  late AppTheme _theme;
  late OutdoorSummary _summary;

  late List<LineOptions> _allLineOptions;
  List<LineOptions> get allLineOptions => _allLineOptions;

  LineOptions? _currentLineOptions;
  LineOptions? get currentLineOptions => _currentLineOptions;

  Timer? _lineAnimTimer;

  MapLinesModel(OutdoorSummary summary, AppTheme theme) {
    _summary = summary;
    _theme = theme;
    _initAllLines();
  }

  void _initAllLines() {
    var options = _summary.activities
        ?.map((e) => LineOptions(
              geometry: getActivityLatLngList(e),
              lineColor: _theme.mapPolylineColorHex,
              lineWidth: 8.0,
              lineOpacity: 0.3,
              draggable: false,
            ))
        .toList();
    _allLineOptions = options ?? [];
  }

  void showRouteAnim(OutdoorActivity activity,
      {int durationMs = 3000, int delayMs = 2000, int intervalMs = 30}) {
    stopRouteAnim();
    var coords = getActivityLatLngList(activity);
    if (coords.isEmpty) {
      return;
    }
    _currentLineOptions = LineOptions(
      geometry: [],
      lineColor: _theme.mapPolylineColorHex,
      lineWidth: 10.0,
      lineOpacity: 0.7,
      draggable: false,
    );
    notifyListeners();
    var len = coords.length;
    var step = len / (durationMs * 1.0 / intervalMs);
    var start = 0;
    var end = start + step;
    _lineAnimTimer =
        periodicImmediately(Duration(milliseconds: intervalMs), (timer) {
      if (end > len) {
        timer.cancel();
        return;
      }
      if (timer.tick < delayMs / intervalMs) {
        return;
      }
      _currentLineOptions?.geometry?.clear();
      _currentLineOptions?.geometry?.addAll(coords.sublist(0, end.floor()));
      end += step;
      notifyListeners();
    });
  }

  void stopRouteAnim() {
    _lineAnimTimer?.cancel();
    _currentLineOptions = null;
    notifyListeners();
  }

  void showAllRoutes() {
    stopRouteAnim();
    notifyListeners();
  }
}
