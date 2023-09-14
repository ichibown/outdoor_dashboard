import 'package:mapbox_gl/mapbox_gl.dart';

import '../data/local.dart';

extension ActivityExts on OutdoorActivity {
  List<LatLng> latLngList() =>
      sparsedCoords
          ?.map((c) => LatLng(c[0] as double, c[1] as double))
          .toList() ??
      [];

  DateTime startDate() =>
      DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true)
          .add(Duration(milliseconds: timeOffset));
}

extension DateTimeExts on DateTime {
  String yyyyMM() {
    return '$year/$month';
  }
}
