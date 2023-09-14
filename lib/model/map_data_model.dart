import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../data/local.dart';
import '../utils/app_const.dart';
import '../utils/app_ext.dart';
import '../utils/utils.dart';

class MapDataModel extends ChangeNotifier {
  static const _padding = 40.0;

  late MapState _mapState;
  MapState get mapState => _mapState;

  final List<List<LatLng>> _allLines = [];
  late OutdoorSummary _summary;
  late LatLngBounds _allPointsBounds;

  MapDataModel(OutdoorSummary summary) {
    _mapState = EmptyMap(mapInitCamera);
    _summary = summary;
    _allLines.addAll(
      _summary.activities?.map((e) => e.latLngList()).toList() ?? [],
    );
    var points = _allLines.expand((element) => element).toList();
    _allPointsBounds = getPointsBounds(points, coverage: 0.90);
  }

  void showEmpty() {
    _mapState = EmptyMap(mapInitCamera);
    notifyListeners();
  }

  void showSingleRoute(OutdoorActivity activity, int durationMs) {
    var coords = activity.latLngList();
    if (coords.isEmpty) {
      return;
    }
    var latlngList = activity.latLngList();
    var bounds = getRouteBounds(latlngList);
    var camera = CameraUpdate.newLatLngBounds(bounds,
        left: _padding, top: _padding, right: _padding, bottom: _padding);
    _mapState = SingleLineMap(camera, durationMs, latlngList);
    notifyListeners();
  }

  void showAllRoutes() {
    _mapState = AllLinesMap(
      CameraUpdate.newLatLngBounds(_allPointsBounds),
      _allLines,
    );
    notifyListeners();
  }
}

sealed class MapState {
  final CameraUpdate camera;

  MapState(this.camera);
}

class EmptyMap extends MapState {
  EmptyMap(super.camera);
}

class SingleLineMap extends MapState {
  final int durationMs;
  final List<LatLng> linePoints;

  SingleLineMap(
    super.camera,
    this.durationMs,
    this.linePoints,
  );
}

class AllLinesMap extends MapState {
  final List<List<LatLng>> linePointsList;

  AllLinesMap(
    super.camera,
    this.linePointsList,
  );
}
