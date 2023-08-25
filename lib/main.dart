import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

const _keyMapbox = "MAPBOX_ACCESS_TOKEN";
var _mapboxToken = "";

void main() {
  _mapboxToken = const String.fromEnvironment(_keyMapbox);
  runApp(const HeatmapApp());
}

String getMapboxToken() {
  return _mapboxToken;
}

class HeatmapApp extends StatelessWidget {
  const HeatmapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outdoor Heatmap (Working in Progress)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
        accessToken: getMapboxToken(),
        initialCameraPosition: const CameraPosition(
            target: LatLng(39.913604, 116.411735), zoom: 11));
  }
}
