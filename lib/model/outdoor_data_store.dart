import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heatmap/utils/utils.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path/path.dart' as path;

import '../utils/app_const.dart';
import '../utils/const.dart';
import '../data/local.dart';

/// Outdoor data loading and calculating from /assets/outdoor_data.
/// Result in a few in-memory outdoor data / state for UI rendering.
enum PolylineState {
  none,
  all,
  single,
}

class OutdoorDataModel extends ChangeNotifier {
  final AppTheme _theme = lightTheme;
  AppTheme get theme => _theme;

  LatLngBounds _cameraBounds =
      LatLngBounds(southwest: mapInitPos, northeast: mapInitPos);
  LatLngBounds get cameraBounds => _cameraBounds;

  final List<LatLng> _animatingLine = [];
  List<LatLng> get animatingLine => _animatingLine;

  final List<List<LatLng>> _allLines = [];
  List<List<LatLng>> get allLines => _allLines;

  PolylineState _lineState = PolylineState.none;
  PolylineState get lineState => _lineState;

  Timer? _routeChangeTimer;
  Timer? _lineAnimTimer;

  Future<void> loadData() async {
    String summaryJson = await rootBundle.loadString(
        path.join(assetsFolder, outdoorDataFolder, summaryFilePath));
    var summary = OutdoorSummary.fromJson(summaryJson);
    _initAllLines(summary);
  }

  void _initAllLines(OutdoorSummary summary) {
    _allLines.clear();
    summary.activities?.forEach((e) {
      _allLines.add(e.sparsedCoords
              ?.map((coord) => LatLng(coord[0] as double, coord[1] as double))
              .toList() ??
          []);
    });
  }

  void changeState(PolylineState state) {
    if (_lineState != state) {
      _lineState = state;
      _routeChangeTimer?.cancel();
      _lineAnimTimer?.cancel();
      notifyListeners();
    }
  }

  void toggleState() {
    if (_lineState == PolylineState.all) {
      changeState(PolylineState.none);
      randomRoute();
    } else {
      _cameraBounds = mapInitBounds;
      changeState(PolylineState.none);
      changeState(PolylineState.all);
    }
  }

  void _animteLine(List<LatLng> lineCoords) {
    _lineAnimTimer?.cancel();
    var len = lineCoords.length;
    var animIntervalMs = 30;
    var animDurationMs = 3000;
    var step = (len / (animDurationMs / animIntervalMs)).floor();
    var start = 0;
    var end = start + step;
    _lineAnimTimer =
        Timer.periodic(Duration(milliseconds: animIntervalMs), (timer) {
      if (end > len) {
        _lineAnimTimer?.cancel();
        return;
      }
      _animatingLine.clear();
      _animatingLine.addAll(lineCoords.sublist(0, end));
      end += step;
      notifyListeners();
    });
  }

  void randomRoute() {
    changeState(PolylineState.single);
    _routeChangeTimer = periodicImmediately(const Duration(seconds: 8), () {
      var lineCoords = _allLines[Random().nextInt(_allLines.length)];
      _cameraBounds = getRouteBounds(lineCoords);
      notifyListeners();
      _animteLine(lineCoords);
    });
  }
}
