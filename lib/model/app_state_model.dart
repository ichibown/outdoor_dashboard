import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path/path.dart' as path;

import '../data/config.dart';
import '../data/local.dart';
import '../utils/const.dart';

/// Model to store app data and state.
class AppStateModel extends ChangeNotifier {
  OutdoorSummary? _summary;
  OutdoorSummary? get summary => _summary;

  AppConfig? _config;
  AppConfig? get config => _config;

  LatLng? _centerCoord;
  LatLng? get centerCoord => _centerCoord;

  void loadData() async {
    String summaryJson = await rootBundle.loadString(
        path.join(assetsFolder, outdoorDataFolder, summaryFilePath));
    _summary = OutdoorSummary.fromJson(summaryJson);
    String configJson =
        await rootBundle.loadString(path.join(assetsFolder, configFilePath));
    _config = AppConfig.fromJson(configJson);
    notifyListeners();
  }
}
