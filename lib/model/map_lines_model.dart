import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../data/config.dart';
import '../data/local.dart';
import '../utils/app_const.dart';
import '../utils/utils.dart';

/// Model to handle polylines on map.
/// todo: refactor.
class MapLinesModel extends ChangeNotifier {
  late OutdoorSummary _summary;
  late AppConfig _config;

  late AppTheme _theme;
  AppTheme get theme => _theme;

  late List<LineOptions> _allLineOptions;
  List<LineOptions> get allLineOptions => _allLineOptions;

  LineOptions? _currentLineOptions;
  LineOptions? get currentLineOptions => _currentLineOptions;
  bool get isRouteAnimating => _currentLineOptions != null;

  Timer? _lineAnimTimer;

  MapLinesModel(OutdoorSummary summary, AppConfig config, bool isDark) {
    _summary = summary;
    _config = config;
    _updateTheme(isDark);
    _initLines();
  }

  void _initLines() {
    var options = _summary.activities
        ?.map((e) => LineOptions(
              geometry: getActivityLatLngList(e),
              lineColor: _theme.mapLineColor,
              lineWidth: 8.0,
              lineOpacity: 0.3,
              draggable: false,
            ))
        .toList();
    _allLineOptions = options ?? [];
  }

  void _updateTheme(bool isDark) {
    if (isDark) {
      _theme = AppTheme(
        mapStyle: _config.mapStyleDark ?? '',
        mapLineColor: _config.mapLineColorDark ?? '',
      );
    } else {
      _theme = AppTheme(
        mapStyle: _config.mapStyleLight ?? '',
        mapLineColor: _config.mapLineColorLight ?? '',
      );
    }
  }

  void changeTheme(bool isDark) {
    _updateTheme(isDark);
    var newOptions = _allLineOptions
        .map((e) => e.copyWith(LineOptions(lineColor: _theme.mapLineColor)))
        .toList();
    _allLineOptions.clear;
    _allLineOptions.addAll(newOptions);
    notifyListeners();
  }

  void showRouteAnim(OutdoorActivity activity,
      {int durationMs = 3000,
      int delayMs = 2000,
      int intervalMs = 16,
      Function? onEnd}) {
    stopRouteAnim();
    var coords = getActivityLatLngList(activity);
    if (coords.isEmpty) {
      return;
    }
    _currentLineOptions = LineOptions(
      geometry: [],
      lineColor: _theme.mapLineColor,
      lineWidth: 10.0,
      lineOpacity: 0.5,
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
        onEnd?.call();
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
