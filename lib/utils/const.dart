// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:mapbox_gl/mapbox_gl.dart';

const assetsFolder = 'assets';
const outdoorDataFolder = 'outdoor_data';
const summaryFilePath = 'summary.json';
const gpxFolder = 'gpx';

class AppTheme {
  final String mapStyle;
  final String mapPolylineColorHex;

  const AppTheme({
    required this.mapStyle,
    required this.mapPolylineColorHex,
  });
}

const darkTheme = AppTheme(
  mapStyle: MapboxStyles.DARK,
  mapPolylineColorHex: '#24C789',
);

const lightTheme = AppTheme(
  mapStyle: MapboxStyles.LIGHT,
  mapPolylineColorHex: '#24C789',
);
