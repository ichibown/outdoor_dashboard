import 'dart:convert';

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
  int? startTime;

  /// Activity timezone offset millis.
  int? timeOffset;

  /// Moving time in seconds.
  int? movingTime;

  /// Elapsed time in seconds.
  int? elapsedTime;

  /// Total distance in meters.
  double? totalDistance;

  /// Accumulated elevation in meters.
  double? accElevation;

  /// Average elevation in meters.
  double? avgElevation;

  /// Highest elevation in meters.
  double? maxElevation;

  /// Average pace in s/1km.
  double? avgPace;

  /// Max pace in s/1km.
  double? maxPace;

  /// Average heartrate.
  double? avgHeartrate;

  /// Max heartrate.
  double? maxHeartrate;

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

  /// Sparsed coords, encoded by google polyline algorithm + gzip + base64.
  String? encodedPolyline;

  OutdoorActivity({
    this.startTime,
    this.timeOffset,
    this.movingTime,
    this.elapsedTime,
    this.totalDistance,
    this.accElevation,
    this.avgElevation,
    this.maxElevation,
    this.avgPace,
    this.maxPace,
    this.avgHeartrate,
    this.maxHeartrate,
    this.startLatlng,
    this.startPlaceName,
    this.type,
    this.source,
    this.sourceId,
    this.gpxFileName,
    this.encodedPolyline,
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
      'encodedPolyline': encodedPolyline,
    };
  }

  factory OutdoorActivity.fromMap(Map<String, dynamic> map) {
    return OutdoorActivity(
      startTime: map['startTime'] != null ? map['startTime'] as int : null,
      timeOffset: map['timeOffset'] != null ? map['timeOffset'] as int : null,
      movingTime: map['movingTime'] != null ? map['movingTime'] as int : null,
      elapsedTime:
          map['elapsedTime'] != null ? map['elapsedTime'] as int : null,
      totalDistance:
          map['totalDistance'] != null ? map['totalDistance'] as double : null,
      accElevation:
          map['accElevation'] != null ? map['accElevation'] as double : null,
      avgElevation:
          map['avgElevation'] != null ? map['avgElevation'] as double : null,
      maxElevation:
          map['maxElevation'] != null ? map['maxElevation'] as double : null,
      avgPace: map['avgPace'] != null ? map['avgPace'] as double : null,
      maxPace: map['maxPace'] != null ? map['maxPace'] as double : null,
      avgHeartrate:
          map['avgHeartrate'] != null ? map['avgHeartrate'] as double : null,
      maxHeartrate:
          map['maxHeartrate'] != null ? map['maxHeartrate'] as double : null,
      startLatlng: map['startLatlng'] != null
          ? map['startLatlng'] as List<double>
          : null,
      startPlaceName: map['startPlaceName'] != null
          ? map['startPlaceName'] as List<String>
          : null,
      type: map['type'] != null ? Type.values.byName(map['type']) : null,
      source:
          map['source'] != null ? Source.values.byName(map['source']) : null,
      sourceId: map['sourceId'] != null ? map['sourceId'] as String : null,
      gpxFileName:
          map['gpxFileName'] != null ? map['sourceId'] as String : null,
      encodedPolyline: map['encodedPolyline'] != null
          ? map['encodedPolyline'] as String
          : null,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory OutdoorActivity.fromJson(String source) => OutdoorActivity.fromMap(
      jsonDecode(source)(source) as Map<String, dynamic>);
}
