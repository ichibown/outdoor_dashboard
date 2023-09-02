import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gpx/gpx.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../data/local.dart';

Future<String> loadTextAsset(String path) async {
  return await rootBundle.loadString(path);
}

Future<Gpx> loadGpxAsset(String path) async {
  var content = await loadTextAsset(path);
  return GpxReader().fromString(content);
}

Timer periodicImmediately(Duration duration, Function() action) {
  action.call();
  return Timer.periodic(duration, (timer) => action.call());
}

List<LatLng> getActivityLatLngList(OutdoorActivity activity) {
  return activity.sparsedCoords
          ?.map((c) => LatLng(c[0] as double, c[1] as double))
          .toList() ??
      [];
}

LatLngBounds getRouteBounds(List<LatLng> route) {
  if (route.isEmpty) {
    return LatLngBounds(
      southwest: const LatLng(0, 0),
      northeast: const LatLng(0, 0),
    );
  }
  var maxLat = route.first.latitude;
  var maxLng = route.first.longitude;
  var minLat = maxLat;
  var minLng = maxLng;
  for (var p in route) {
    if (p.latitude > maxLat) {
      maxLat = p.latitude;
    }
    if (p.latitude < minLat) {
      minLat = p.latitude;
    }
    if (p.longitude > maxLng) {
      maxLng = p.longitude;
    }
    if (p.longitude < minLng) {
      minLng = p.longitude;
    }
  }
  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}
