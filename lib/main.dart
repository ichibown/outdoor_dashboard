import 'package:flutter/material.dart';
import 'package:heatmap/model/outdoor_data_store.dart';
import 'package:heatmap/ui/main_page.dart';
import 'package:provider/provider.dart';

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
    return ChangeNotifierProvider(
      create: (context) => OutdoorDataModel(),
      child: MaterialApp(
        title: 'Outdoor Heatmap (Working in Progress)',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainPage(),
      ),
    );
  }
}
