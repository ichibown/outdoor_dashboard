import 'package:mapbox_gl/mapbox_gl.dart';

/// Const values for App.

/// Beijing National Stadium
const mapInitPos = LatLng(39.9929471, 116.3916403);
var mapInitCamera = CameraUpdate.newCameraPosition(
  const CameraPosition(target: mapInitPos, zoom: 10),
);

class AppTheme {
  final String mapStyle;
  final String mapLineColor;

  const AppTheme({
    required this.mapStyle,
    required this.mapLineColor,
  });
}

const defaultThtme = AppTheme(
  mapStyle: 'mapbox://styles/mapbox/light-v10',
  mapLineColor: '#24C789',
);
