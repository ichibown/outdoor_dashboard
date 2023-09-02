import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../data/local.dart';
import '../utils/utils.dart';
import '../utils/app_const.dart';

/// Model to handle map camera position.
class MapCameraModel extends ChangeNotifier {
  CameraUpdate _cameraUpdate = CameraUpdate.newLatLngBounds(mapInitBounds);
  CameraUpdate get cameraUpdate => _cameraUpdate;

  void moveToDefault() {
    _cameraUpdate = CameraUpdate.newLatLngBounds(mapInitBounds);
    notifyListeners();
  }

  void moveToRoute(OutdoorActivity activity) {
    var latlngList = getActivityLatLngList(activity);
    var bounds = getRouteBounds(latlngList);
    _cameraUpdate = CameraUpdate.newLatLngBounds(bounds,
        left: 40, top: 40, right: 40, bottom: 40);
    notifyListeners();
  }
}
