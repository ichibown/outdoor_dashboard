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

Timer periodicImmediately(Duration duration, Function(Timer) action) {
  var timer = Timer.periodic(duration, action);
  action.call(timer);
  return timer;
}

List<LatLng> getActivityLatLngList(OutdoorActivity activity) {
  return activity.sparsedCoords
          ?.map((c) => LatLng(c[0] as double, c[1] as double))
          .toList() ??
      [];
}

/// find bounds to cover route points.
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

/// find min bounds which contains [coverage] points.
LatLngBounds getPointsBounds(List<LatLng> points, {double coverage = 0.9}) {
  points.sort((a, b) => a.latitude.compareTo(b.latitude));
  double lat1 = points[(points.length * (1 - coverage)).round()].latitude;
  double lat2 = points[(points.length * coverage).round()].latitude;

  points.sort((a, b) => a.longitude.compareTo(b.longitude));
  double lng1 = points[(points.length * 0.1).round()].longitude;
  double lng2 = points[(points.length * 0.9).round()].longitude;

  return LatLngBounds(
    southwest: LatLng(lat1, lng1),
    northeast: LatLng(lat2, lng2),
  );
}

/// interpolate more points to make anim smoother.
List<LatLng> getInterpolatedPoints(List<LatLng> points, {int threshold = 150}) {
  while (points.length > 2 && points.length < threshold) {
    var result = <LatLng>[];
    for (var i = 0; i < points.length - 2; i++) {
      result.add(points[i]);
      result.add(LatLng(
        (points[i].latitude + points[i + 1].latitude) / 2,
        (points[i].longitude + points[i + 1].longitude) / 2,
      ));
      result.add(points[i + 1]);
    }
    points = result;
  }
  return points;
}
