import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../ui/main_page.dart';

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
      create: (context) => AppStateModel(),
      child: MaterialApp(
        title: 'Outdoor Heatmap (Working in Progress)',
        theme: ThemeData(useMaterial3: true),
        home: const MainPage(),
      ),
    );
  }
}
