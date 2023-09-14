import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:gpx/gpx.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../data/local.dart';
import '../data/strava.dart';
import '../utils/const.dart';
import '../utils/ext.dart';

// ignore_for_file: avoid_print

/// Dart script to sync Strava activities and GPX data.
/// Using Strava API [https://developers.strava.com/docs/reference/]
///
/// Strava auth:
/// > dart run lib/scripts/sync_strava.dart auth <clientID> <clientSecret>
///
/// Strava sync:
/// > dart run lib/scripts/sync_strava.dart sync <clientID> <clientSecret> <refreshToken>

var _errorPen = AnsiPen()..red(bold: true);
var _infoPen = AnsiPen()..green(bold: true);
var _outdoorDataPath = path.join(
    File(Platform.script.path).parent.parent.parent.path,
    assetsFolder,
    outdoorDataFolder);

enum _StravaApiErrorCode {
  /// API call rate limit. (200 / 15min && 2000 / 1day)
  exceeded,
}

class _StravaApiException implements Exception {
  String message;
  _StravaApiErrorCode? code;

  _StravaApiException({
    required this.message,
    this.code,
  });

  factory _StravaApiException.fromResponseBody(String api, String respBody) {
    var respJson = jsonDecode(respBody);
    var message = respJson['message'];
    var code = (respJson['errors'] as List<dynamic>?)?[0]?['code'];
    return _StravaApiException(
      message: 'Request $api failed: $message',
      code: _StravaApiErrorCode.values.byNameWithCatch(code),
    );
  }
}

Future<void> main(List<String> args) async {
  switch (args[0]) {
    case 'auth':
      if (args.length >= 3) {
        await _auth(args[1], args[2]).onError(
          (error, stackTrace) => print(_errorPen('$error\n$stackTrace')),
        );
      } else {
        print(_errorPen('Missing ClientID or ClientSecret'));
        return;
      }
      break;
    case 'sync':
      if (args.length >= 4) {
        await _sync(args[1], args[2], args[3]).onError(
          (error, stackTrace) => print(_errorPen('$error\n$stackTrace')),
        );
      } else {
        print(_errorPen('Missing ClientID or ClientSecret or RefreshToken'));
        return;
      }
      break;
  }
}

Future<void> _auth(String clientId, String clientSecret) async {
  var url =
      'https://www.strava.com/oauth/authorize?client_id=${clientId}&response_type=code&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=read_all,profile:read_all,activity:read_all,profile:write,activity:write';
  await Process.run('open', [url]);
  print(_infoPen('Open the URL below in browser to auth Strava:'));
  print(url);
  print(_infoPen(
      'Click the [Authorize] button, copy the redirected URL and paste it below:'));
  var result = stdin.readLineSync();
  if (result == null || result.isEmpty) {
    throw Exception('Auth failed, invalid URL.');
  }
  var code = Uri.parse(result).queryParameters['code'];
  if (code == null || code.isEmpty) {
    throw Exception('Auth failed, code not found.');
  }
  var refreshToken = await _getRefreshToken(clientId, clientSecret, code);
  print(_infoPen('Run the command below to start sync:'));
  print(
      'dart run lib/scripts/sync_strava.dart sync $clientId $clientSecret $refreshToken');
}

Future<void> _sync(
    String clientId, String clientSecret, String refreshToken) async {
  var authToken = await _getAuthToken(clientId, clientSecret, refreshToken);
  try {
    await _syncOutdoorSummary(authToken);
  } catch (e) {
    if (e is _StravaApiException && e.code == _StravaApiErrorCode.exceeded) {
      var duration = const Duration(minutes: 15);
      print('API rate limit exceeded, wait for ${duration.inMinutes} minutes.');
      sleep(duration);
      // restart sync after sleep.
      await _sync(clientId, clientSecret, refreshToken);
    } else {
      rethrow;
    }
  }
}

/// Sync strava activities to local summary file.
Future<OutdoorSummary> _syncOutdoorSummary(String authToken) async {
  print(_infoPen('Fetching Strava activities...'));
  var stravaActivites = await _getAllActivities(authToken);
  print('Got ${stravaActivites.length} activities.');
  var summary = _convertStravaActivities(stravaActivites);
  print(_infoPen('Fetching Strava streams and rebuild GPX files...'));
  summary = await _syncStravaGpx(summary, authToken);

  var localActivitiesFile = File(path.join(_outdoorDataPath, summaryFilePath));
  if (!localActivitiesFile.existsSync()) {
    localActivitiesFile.createSync(recursive: true);
  }
  localActivitiesFile.writeAsStringSync(summary.toJsonWithIndent('  '),
      mode: FileMode.write);
  print(_infoPen('Sync finished, data saved to ${localActivitiesFile.path}.'));
  return summary;
}

OutdoorSummary _convertStravaActivities(List<StravaActivity> activities) {
  OutdoorSummary summary = OutdoorSummary();
  summary.activities = [];
  for (var activity in activities) {
    var stravaStartDate = activity.startDate;
    var startTime = stravaStartDate == null
        ? null
        : DateTime.parse(stravaStartDate).toUtc().millisecondsSinceEpoch;
    var stravaAvgSpeed = activity.averageSpeed;
    var avgPace = stravaAvgSpeed == null || stravaAvgSpeed == 0
        ? null
        : 1000 / stravaAvgSpeed;
    var stravaMaxSpeed = activity.maxSpeed;
    var maxPace = stravaMaxSpeed == null || stravaMaxSpeed == 0
        ? null
        : 1000 / stravaMaxSpeed;
    var stravaStartLatlng = activity.startLatlng;
    var startLaglng = stravaStartLatlng != null && stravaStartLatlng.length == 2
        ? [stravaStartLatlng[0], stravaStartLatlng[1]]
        : null;

    OutdoorActivity outdoorActivity = OutdoorActivity(
      startTime: startTime ?? 0,
      timeOffset: activity.utcOffset?.toInt() ?? 0,
      movingTime: activity.movingTime ?? 0,
      elapsedTime: activity.elapsedTime ?? 0,
      totalDistance: activity.distance ?? 0,
      accElevation: activity.totalElevationGain ?? 0,
      avgPace: avgPace ?? 0,
      maxPace: maxPace ?? 0,
      avgHeartrate: activity.averageHeartrate ?? 0,
      maxHeartrate: activity.maxHeartrate ?? 0,
      startLatlng: startLaglng,
      type:
          Type.values.byNameWithCatch(activity.sportType?.toLowerCase() ?? ''),
      source: Source.strava,
      sourceId: activity.id != null ? '${activity.id}' : null,
    );
    if (outdoorActivity.type == Type.run) {
      summary.activities?.add(outdoorActivity);
    }
  }

  return summary;
}

Future<OutdoorSummary> _syncStravaGpx(
    OutdoorSummary summary, String authToken) async {
  var activities = summary.activities;
  if (activities == null) {
    return summary;
  }
  gpxFileName(OutdoorActivity e) => '${e.source?.name}_${e.sourceId}.gpx';
  for (var activity in activities) {
    var activityId = activity.sourceId;
    if (activityId == null) {
      continue;
    }
    var file =
        File(path.join(_outdoorDataPath, gpxFolder, gpxFileName(activity)));
    Gpx gpx;
    if (!file.existsSync()) {
      // fetch and rebuild gpx file to local.
      var startTime = activity.startTime;
      var streams = await _getActivityStreams(activityId, authToken);
      gpx = _convertStreamsToGpx(streams, startTime);
      var gpxContent = GpxWriter().asString(gpx, pretty: true);
      var gpxFile =
          File(path.join(_outdoorDataPath, gpxFolder, gpxFileName(activity)));
      if (!gpxFile.existsSync()) {
        gpxFile.createSync(recursive: true);
      }
      gpxFile.writeAsStringSync(gpxContent, mode: FileMode.write);
      print('GPX file ${gpxFileName(activity)} generated.');
    } else {
      // load local gpx file.
      gpx = GpxReader().fromString(file.readAsStringSync());
    }
    activity.gpxFileName = gpxFileName(activity);
    // append elevations.
    var wpts = gpx.trks.firstOrNull?.trksegs.firstOrNull?.trkpts;
    var elevations = wpts?.map((e) => e.ele);
    if (elevations != null && elevations.isNotEmpty) {
      var eleMax = 0.0;
      var eleSum = 0.0;
      for (var ele in elevations) {
        ele = ele ?? 0;
        eleSum += ele;
        eleMax = ele > eleMax ? ele : eleMax;
      }
      activity.avgElevation = eleSum / elevations.length;
      activity.maxElevation = eleMax;
    }
    // append sparsed coords
    var coordsSkipCount = 1;
    var wptLength = wpts?.length ?? 0;
    if (wptLength > 1000) {
      coordsSkipCount = 5;
    } else if (wptLength > 600) {
      coordsSkipCount = 3;
    } else if (wptLength > 400) {
      coordsSkipCount = 2;
    }
    activity.sparsedCoords = wpts?.indexed
        .where((e) => e.$1 % coordsSkipCount == 0)
        .map((e) => [e.$2.lat ?? 0, e.$2.lon ?? 0])
        .toList();
  }
  return summary;
}

Gpx _convertStreamsToGpx(StravaStream streams, int startTime) {
  var gpx = Gpx();
  var wpts = <Wpt>[];
  for (var i = 0; i < (streams.time?.length ?? 0); i++) {
    wpts.add(Wpt(
      lat: streams.latlng?[i][0],
      lon: streams.latlng?[i][1],
      ele: streams.altitude?[i],
      time: DateTime.fromMillisecondsSinceEpoch(
          startTime + streams.time![i] * 1000),
      // TODO: timezone?
    ));
  }
  gpx.trks = [
    Trk(name: 'outdoor_dashboard', trksegs: [Trkseg(trkpts: wpts)])
  ];
  return gpx;
}

Future<List<StravaActivity>> _getAllActivities(String refreshToken) async {
  List<StravaActivity> result = [];
  var page = 1;
  var perPage = 100;
  while (true) {
    var activites =
        await _getActivities(refreshToken, page: page, perPage: perPage);
    print('Got ${activites.length} activities on page $page');
    result.addAll(activites);
    if (activites.length == perPage) {
      page++;
    } else {
      break;
    }
  }
  return result;
}

/// Strava API /oauth/token
Future<String> _getRefreshToken(
    String clientId, String clientSecret, String code) async {
  var resp = await http.post(
    Uri.parse('https://www.strava.com/oauth/token'),
    body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
      'grant_type': 'authorization_code'
    },
  );
  if (resp.statusCode != 200) {
    throw _StravaApiException.fromResponseBody('/oauth/token', resp.body);
  }
  return jsonDecode(resp.body)['refresh_token'];
}

/// Strava API /oauth/token
Future<String> _getAuthToken(
    String clientId, String clientSecret, String refreshToken) async {
  var resp = await http.post(
    Uri.parse('https://www.strava.com/oauth/token'),
    body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    },
  );
  if (resp.statusCode != 200) {
    throw _StravaApiException.fromResponseBody('/oauth/token', resp.body);
  }
  return jsonDecode(resp.body)['access_token'];
}

/// Strava API: /api/v3/activities
Future<List<StravaActivity>> _getActivities(String authToken,
    {int page = 1, int perPage = 30}) async {
  var resp = await http.get(
    Uri.parse(
        'https://www.strava.com/api/v3/athlete/activities?page=$page&per_page=$perPage'),
    headers: {
      'Authorization': 'Bearer $authToken',
    },
  );
  if (resp.statusCode != 200) {
    throw _StravaApiException.fromResponseBody('/api/v3/activities', resp.body);
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((e) => StravaActivity.fromMap(e))
      .toList();
}

/// Strava API: /api/v3/activities/{id}/streams
Future<StravaStream> _getActivityStreams(
    String activityId, String authToken) async {
  var resp = await http.get(
    Uri.parse(
        'https://www.strava.com/api/v3/activities/$activityId/streams?keys=latlng,altitude,time&key_by_type=true'),
    headers: {
      'Authorization': 'Bearer $authToken',
    },
  );
  if (resp.statusCode != 200) {
    throw _StravaApiException.fromResponseBody(
        '/api/v3/activities/$activityId/streams', resp.body);
  }
  return StravaStream.fromJson(resp.body);
}
