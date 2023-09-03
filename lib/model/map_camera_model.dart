import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../data/local.dart';
import '../utils/utils.dart';
import '../utils/app_const.dart';

/// Model to handle map camera position.
class MapCameraModel extends ChangeNotifier {
  static const padding = 40.0;

  late LatLngBounds _allPointsBounds;

  CameraUpdate _cameraUpdate = mapInitCamera;
  CameraUpdate get cameraUpdate => _cameraUpdate;

  MapCameraModel(OutdoorSummary summary) {
    var points = summary.activities
        ?.map((e) => getActivityLatLngList(e))
        .expand((element) => element)
        .toList();
    _allPointsBounds = getPointsBounds(points ?? [], coverage: 0.90);
  }

  void moveToDefault() {
    _cameraUpdate = CameraUpdate.newLatLngBounds(_allPointsBounds,
        left: padding, top: padding, right: padding, bottom: padding);
    notifyListeners();
  }

  void moveToRoute(OutdoorActivity activity) {
    var latlngList = getActivityLatLngList(activity);
    var bounds = getRouteBounds(latlngList);
    _cameraUpdate = CameraUpdate.newLatLngBounds(bounds,
        left: padding, top: padding, right: padding, bottom: padding);
    notifyListeners();
  }
}
