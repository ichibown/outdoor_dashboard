import 'dart:convert';

import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

/// Unified local JSON models.
/// Used for local file storage and runtime rendering.

class OutdoorSummary {
  /// All outdoor activities.
  List<OutdoorActivity>? activities;

  OutdoorSummary({
    this.activities,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'activities': activities?.map((x) => x.toMap()).toList(),
    };
  }

  factory OutdoorSummary.fromMap(Map<String, dynamic> map) {
    return OutdoorSummary(
      activities: map['activities'] != null
          ? (map['activities'] as List<dynamic>)
              .map((e) => OutdoorActivity.fromMap(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  String toJsonWithIndent(String indent) =>
      JsonEncoder.withIndent(indent).convert(toMap());

  factory OutdoorSummary.fromJson(String source) =>
      OutdoorSummary.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Activity source platform.
enum Source {
  strava,
  garmin,
  keep,
}

/// Activity type.
enum Type {
  run,
}

class OutdoorActivity {
  /// Start time in UTC millis.
  int startTime;

  /// Activity timezone offset millis.
  int timeOffset;

  /// Moving time in seconds.
  int movingTime;

  /// Elapsed time in seconds.
  int elapsedTime;

  /// Total distance in meters.
  double totalDistance;

  /// Accumulated elevation in meters.
  double accElevation;

  /// Average elevation in meters.
  double avgElevation;

  /// Highest elevation in meters.
  double maxElevation;

  /// Average pace in s/1km.
  double avgPace;

  /// Max pace in s/1km.
  double maxPace;

  /// Average heartrate.
  double avgHeartrate;

  /// Max heartrate.
  double maxHeartrate;

  /// Activity start geo location.
  List<double>? startLatlng;

  /// Actifity start place name: country / province or state / city.
  List<String>? startPlaceName;

  /// Outdoor activity type.
  Type? type;

  /// Source platform.
  Source? source;

  /// Source platform activity id.
  String? sourceId;

  /// GPX file name in gpx data folder.
  String? gpxFileName;

  /// Sparsed location coordinates from raw GPX.
  /// Codec by google polyline algorithm when [toMap]/[fromMap].
  List<List<num>>? sparsedCoords;

  OutdoorActivity({
    this.startTime = 0,
    this.timeOffset = 0,
    this.movingTime = 0,
    this.elapsedTime = 0,
    this.totalDistance = 0,
    this.accElevation = 0,
    this.avgElevation = 0,
    this.maxElevation = 0,
    this.avgPace = 0,
    this.maxPace = 0,
    this.avgHeartrate = 0,
    this.maxHeartrate = 0,
    this.startLatlng,
    this.startPlaceName,
    this.type,
    this.source,
    this.sourceId,
    this.gpxFileName,
    this.sparsedCoords,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startTime': startTime,
      'timeOffset': timeOffset,
      'movingTime': movingTime,
      'elapsedTime': elapsedTime,
      'totalDistance': totalDistance,
      'accElevation': accElevation,
      'avgElevation': avgElevation,
      'maxElevation': maxElevation,
      'avgPace': avgPace,
      'maxPace': maxPace,
      'avgHeartrate': avgHeartrate,
      'maxHeartrate': maxHeartrate,
      'startLatlng': startLatlng,
      'startPlaceName': startPlaceName,
      'type': type?.name,
      'source': source?.name,
      'sourceId': sourceId,
      'gpxFileName': gpxFileName,
      // encode coords to String.
      'sparsedCoords': encodePolyline(sparsedCoords ?? []),
    };
  }

  factory OutdoorActivity.fromMap(Map<String, dynamic> map) {
    return OutdoorActivity(
      startTime: map['startTime'] as int,
      timeOffset: map['timeOffset'] as int,
      movingTime: map['movingTime'] as int,
      elapsedTime: map['elapsedTime'] as int,
      totalDistance: map['totalDistance'] as double,
      accElevation: map['accElevation'] as double,
      avgElevation: map['avgElevation'] as double,
      maxElevation: map['maxElevation'] as double,
      avgPace: map['avgPace'] as double,
      maxPace: map['maxPace'] as double,
      avgHeartrate: map['avgHeartrate'] as double,
      maxHeartrate: map['maxHeartrate'] as double,
      startLatlng: map['startLatlng'] != null
          ? (map['startLatlng'] as List<dynamic>)
              .map((e) => e as double)
              .toList()
          : null,
      startPlaceName: map['startPlaceName'] != null
          ? (map['startPlaceName'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
          : null,
      type: map['type'] != null ? Type.values.byName(map['type']) : null,
      source:
          map['source'] != null ? Source.values.byName(map['source']) : null,
      sourceId: map['sourceId'] != null ? map['sourceId'] as String : null,
      gpxFileName:
          map['gpxFileName'] != null ? map['sourceId'] as String : null,
      // decode coords from JSON.
      sparsedCoords: map['sparsedCoords'] != null
          ? decodePolyline(map['sparsedCoords'] as String)
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory OutdoorActivity.fromJson(String source) => OutdoorActivity.fromMap(
      jsonDecode(source)(source) as Map<String, dynamic>);
}
