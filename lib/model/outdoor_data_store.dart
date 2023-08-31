import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heatmap/data/local.dart';
import 'package:heatmap/utils/const.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path/path.dart' as path;

/// Outdoor data loading and calculating from /assets/outdoor_data.
/// Result in a few in-memory outdoor data / state for UI rendering.
class OutdoorDataModel extends ChangeNotifier {
  final AppTheme _theme = lightTheme;
  AppTheme get theme => _theme;

  final List<LineOptions> _polylineOptions = [];
  List<LineOptions> get polylineOptions => _polylineOptions;

  Future<void> loadData() async {
    String summaryJson = await rootBundle
        .loadString(path.join(outdoorDataFolder, summaryFilePath));
    var summary = OutdoorSummary.fromJson(summaryJson);
    _buildPolylines(summary);
  }

  void _buildPolylines(OutdoorSummary summary) {
    _polylineOptions.clear();
    summary.activities?.forEach((e) {
      _polylineOptions.add(
        LineOptions(
          geometry: e.sparsedCoords
              ?.map((coord) => LatLng(coord[0] as double, coord[1] as double))
              .toList(),
          lineColor: _theme.mapPolylineColorHex,
          lineWidth: 8.0,
          lineOpacity: 0.3,
          draggable: false,
        ),
      );
    });
    notifyListeners();
  }
}
