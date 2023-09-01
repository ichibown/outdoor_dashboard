import 'package:mapbox_gl/mapbox_gl.dart';

/// Const values for App.

const mapInitPos = LatLng(39.913604, 116.411735);

class AppTheme {
  final String mapStyle;
  final String mapPolylineColorHex;

  const AppTheme({
    required this.mapStyle,
    required this.mapPolylineColorHex,
  });
}

const darkTheme = AppTheme(
  mapStyle: "mapbox://styles/mapbox/dark-v10",
  mapPolylineColorHex: '#24C789',
);

const lightTheme = AppTheme(
  mapStyle: "mapbox://styles/mapbox/light-v10",
  mapPolylineColorHex: '#24C789',
);
