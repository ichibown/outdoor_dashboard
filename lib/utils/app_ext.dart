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

  String hms() {
    return elapsedTime.hms();
  }

  String pace() {
    return avgPace.toInt().pace();
  }

  int animDurationSeconds() {
    var animMinSecond = 5;
    var duration = elapsedTime ~/ 500;
    return duration <= animMinSecond ? animMinSecond : duration;
  }
}

extension DateTimeExts on DateTime {
  String yyyyMM() {
    return '$year/$month';
  }

  String yyyyMMdd() {
    return '$year/$month/$day';
  }
}

extension TimeSecondsExts on int {
  String hms() {
    return '${(this ~/ 3600).toString().padLeft(2, '0')}'
        ':${(this % 3600 ~/ 60).toString().padLeft(2, '0')}'
        ':${(this % 60).toString().padLeft(2, '0')}';
  }

  String pace() {
    return '${this ~/ 60}\'${this % 60}"';
  }
}
