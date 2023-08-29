import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heatmap/data/local.dart';
import 'package:heatmap/utils/const.dart';
import 'package:path/path.dart' as path;

/// Outdoor data loading and calculating from /assets/outdoor_data
/// Result in a few in-memory outdoor data for UI rendering.
class OutdoorDataStore {
  OutdoorActivity? _pb5k = null;
  OutdoorActivity? _pb10k = null;
  OutdoorActivity? _pbHM = null;
  OutdoorActivity? _pbFM = null;

  Future<void> loadData() async {
    String summaryJson = await rootBundle
        .loadString(path.join(outdoorDataFolder, summaryFilePath));
    var summary = OutdoorSummary.fromJson(summaryJson);
    debugPrint('coords: ${summary.activities?.last.sparsedCoords}');
  }
}

class YearlyData {
  double distance = 0;
  double duration = 0;
  double elevation = 0;
  int count = 0;
  int avgPace = 0;
  int avgHr = 0;
}
