import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../data/local.dart';
import '../data/strava.dart';
import '../utils/const.dart';

// ignore_for_file: avoid_print

/// Dart script to sync Strava activities and GPX data.
/// Using Strava API [https://developers.strava.com/docs/reference/]
///
/// Strava auth:
/// > dart run lib/scripts/sync_strava.dart auth <clientID> <clientSecret>
///
/// Strava sync:
/// > dart run lib/scripts/sync_strava.dart sync <clientID> <clientSecret> <refreshToken>

Future<void> main(List<String> args) async {
  AnsiPen errorPen = AnsiPen()..red(bold: true);
  switch (args[0]) {
    case 'auth':
      if (args.length >= 3) {
        await _auth(args[1], args[2]).onError((error, stackTrace) =>
            print(errorPen('ERROR: $error\n$stackTrace')));
      } else {
        print(errorPen('ERROR: Missing ClientID or ClientSecret'));
        return;
      }
      break;
    case 'sync':
      if (args.length >= 4) {
        await _sync(args[1], args[2], args[3]).onError((error, stackTrace) =>
            print(errorPen('ERROR: $error\n$stackTrace')));
      } else {
        print(errorPen(
            'ERROR: Missing ClientID or ClientSecret or RefreshToken'));
        return;
      }
      break;
  }
}

Future<void> _auth(String clientId, String clientSecret) async {
  var url =
      'https://www.strava.com/oauth/authorize?client_id=${clientId}&response_type=code&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=read_all,profile:read_all,activity:read_all,profile:write,activity:write';
  await Process.run('open', [url]);
  AnsiPen greenPen = AnsiPen()..green();
  print('${greenPen('Open browser to auth Strava:')} $url');
  print(greenPen('> Click the [Authorize] button.'));
  print(greenPen(
      '> Then copy the redirected URL and ${greenPen('paste it below:')}'));
  var result = stdin.readLineSync();
  if (result == null || result.isEmpty) {
    throw Exception('Auth failed, invalid URL.');
  }
  var code = Uri.parse(result).queryParameters['code'];
  if (code == null || code.isEmpty) {
    throw Exception('Auth failed, code not found.');
  }
  var refreshToken = await _getRefreshToken(clientId, clientSecret, code);
  print('\n');
  print('Auth finished, the refresh token is ${greenPen(refreshToken)}');
  print('Run following command to start sync:\n> ');
  print(greenPen(
      'dart run lib/scripts/sync_strava.dart sync $clientId $clientSecret $refreshToken'));
}

Future<void> _sync(
    String clientId, String clientSecret, String refreshToken) async {
  var authToken = await _getAuthToken(clientId, clientSecret, refreshToken);
  await _syncOutdoorSummary(authToken);
}

/// Sync strava activities to local summary file.
/// - 1. fetch all StravaActivity.
/// - 2. convert to local OutdoorSummary.
/// - 3. fetch all activities' gpx and save to local.
/// - 4. save OutdoorSummary to local.
Future<void> _syncOutdoorSummary(String authToken) async {
  var stravaActivites = await _getAllActivities(authToken);
  var summary = _convertStravaActivities(stravaActivites);
  summary = await _syncStravaGpx(summary, authToken);

  var rootPath = File(Platform.script.path).parent.parent.parent.path;
  var dstPath = '$assetsFolder/$outdoorDataFolder/$summaryFilePath';
  var localActivitiesFile = File(path.join(rootPath, dstPath));
  if (!localActivitiesFile.existsSync()) {
    localActivitiesFile.createSync(recursive: true);
  }
  localActivitiesFile.writeAsStringSync(summary.toJson(), mode: FileMode.write);
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
      startTime: startTime,
      timeOffset: activity.utcOffset?.toInt(),
      movingTime: activity.movingTime,
      elapsedTime: activity.elapsedTime,
      totalDistance: activity.distance,
      accElevation: activity.totalElevationGain,
      avgPace: avgPace,
      maxPace: maxPace,
      startLatlng: startLaglng,
      type: Type.running,
      source: Source.strava,
      sourceId: activity.id != null ? '${activity.id}' : null,
    );
    summary.activities?.add(outdoorActivity);
  }

  return summary;
}

Future<OutdoorSummary> _syncStravaGpx(
    OutdoorSummary summary, String authToken) async {
  // TODO: sync all gpx
  return summary;
}

Future<List<StravaActivity>> _getAllActivities(String refreshToken) async {
  List<StravaActivity> result = [];
  var page = 1;
  var perPage = 100;
  while (true) {
    var activites =
        await _getActivities(refreshToken, page: page, perPage: perPage);
    result.addAll(activites);
    print('Got ${activites.length} activities on page $page');
    if (activites.length == perPage) {
      page++;
    } else {
      break;
    }
  }
  return result;
}

/// Strava API oauth/token
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
    throw Exception('Get refresh token failed: ${resp.body}');
  }
  return jsonDecode(resp.body)['refresh_token'];
}

/// Strava API oauth/token
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
    throw Exception('Get auth token failed: ${resp.body}');
  }
  return jsonDecode(resp.body)['access_token'];
}

/// Strava API: api/v3/activities
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
    throw Exception('Get activities failed: ${resp.body}');
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((e) => StravaActivity.fromMap(e))
      .toList();
}

/// Strava API: api/v3/activities/{id}/streams
Future<List<StravaStream>> _getActivityStreams(
    String activityId, String authToken) async {
  var resp = await http.get(
    Uri.parse(
        'https://www.strava.com/api/v3/activities/$activityId/streams?keys=latlng,altitude,time'),
    headers: {
      'Authorization': 'Bearer $authToken',
    },
  );
  if (resp.statusCode != 200) {
    throw Exception('Get activity streams failed: ${resp.body}');
  }
  return (jsonDecode(resp.body) as List<dynamic>)
      .map((e) => StravaStream.fromMap(e))
      .toList();
}
