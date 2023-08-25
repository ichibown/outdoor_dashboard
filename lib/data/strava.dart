// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Strava API JSON Models
class StravaActivity {
  double? distance;
  int? movingTime;
  int? elapsedTime;
  double? totalElevationGain;
  String? sportType;
  int? id;
  String? startDate;
  double? utcOffset;
  List<double>? startLatlng;
  List<double>? endLatlng;
  double? averageSpeed;
  double? maxSpeed;
  double? elevHigh;
  double? elevLow;

  StravaActivity({
    this.distance,
    this.movingTime,
    this.elapsedTime,
    this.totalElevationGain,
    this.sportType,
    this.id,
    this.startDate,
    this.utcOffset,
    this.startLatlng,
    this.endLatlng,
    this.averageSpeed,
    this.maxSpeed,
    this.elevHigh,
    this.elevLow,
  });

  factory StravaActivity.fromMap(Map<String, dynamic> data) => StravaActivity(
        distance: (data['distance'] as num?)?.toDouble(),
        movingTime: data['moving_time'] as int?,
        elapsedTime: data['elapsed_time'] as int?,
        totalElevationGain: (data['total_elevation_gain'] as num?)?.toDouble(),
        sportType: data['sport_type'] as String?,
        id: data['id'] as int?,
        startDate: data['start_date'] as String?,
        utcOffset: data['utc_offset'] as double?,
        startLatlng: (data['start_latlng'] as List<dynamic>?)
            ?.map((e) => e as double)
            .toList(),
        endLatlng: (data['end_latlng'] as List<dynamic>?)
            ?.map((e) => e as double)
            .toList(),
        averageSpeed: (data['average_speed'] as num?)?.toDouble(),
        maxSpeed: (data['max_speed'] as num?)?.toDouble(),
        elevHigh: data['elev_high'] as double?,
        elevLow: (data['elev_low'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'distance': distance,
        'moving_time': movingTime,
        'elapsed_time': elapsedTime,
        'total_elevation_gain': totalElevationGain,
        'sport_type': sportType,
        'id': id,
        'start_date': startDate,
        'utc_offset': utcOffset,
        'start_latlng': startLatlng,
        'end_latlng': endLatlng,
        'average_speed': averageSpeed,
        'max_speed': maxSpeed,
        'elev_high': elevHigh,
        'elev_low': elevLow,
      };

  factory StravaActivity.fromJson(String data) {
    return StravaActivity.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());
}

class StravaStream {
  List<List<double>>? latlng;
  List<double>? altitude;
  List<int>? time;

  StravaStream({
    this.latlng,
    this.altitude,
    this.time,
  });

  factory StravaStream.fromMap(Map<String, dynamic> map) {
    var latlng = map['latlng'];
    var altitude = map['altitude'];
    var time = map['time'];

    var latlngSize = latlng?['original_size'];
    var altitudeSize = altitude?['original_size'];
    var timeSize = time?['original_size'];

    var latlngData = latlng?['data'] as List<dynamic>?;
    var altitudeData = altitude?['data'] as List<dynamic>?;
    var timeData = time?['data'] as List<dynamic>?;

    var result = StravaStream(
      latlng: null,
      altitude: null,
      time: null,
    );

    if (latlngSize == null || timeSize == null || latlngSize != timeSize) {
      return result;
    }
    if (latlngData == null ||
        timeData == null ||
        latlngData.length != latlngSize ||
        latlngData.length != timeData.length) {
      return result;
    }
    result.latlng = latlngData
        .map((e) => (e as List<dynamic>).map((f) => f as double).toList())
        .toList();
    result.time = timeData.map((e) => e as int).toList();

    if (altitudeSize != latlngSize ||
        altitudeData == null ||
        altitudeData.length != altitudeSize) {
      return result;
    }
    result.altitude = altitudeData.map((e) => e as double).toList();
    return result;
  }

  factory StravaStream.fromJson(String source) =>
      StravaStream.fromMap(json.decode(source) as Map<String, dynamic>);
}
