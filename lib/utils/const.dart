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
  mapStyle: "mapbox://styles/mapbox/dark-v10",
  mapPolylineColorHex: '#24C789',
);

const lightTheme = AppTheme(
  mapStyle: "mapbox://styles/mapbox/light-v10",
  mapPolylineColorHex: '#24C789',
);
