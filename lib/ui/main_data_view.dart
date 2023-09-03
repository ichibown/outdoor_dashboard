import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/map_camera_model.dart';
import '../model/map_lines_model.dart';
import '../utils/utils.dart';

class MainDataView extends StatefulWidget {
  const MainDataView({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainDataViewState();
  }
}

class MainDataViewState extends State<MainDataView> {
  bool _all = false;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: IconButton(
        iconSize: 44,
        onPressed: () => _toggle(),
        icon: const Icon(Icons.map_sharp),
      ),
    );
  }

  void _toggle() {
    var appModel = context.read<AppStateModel>();
    var lineModel = context.read<MapLinesModel>();
    var cameraModel = context.read<MapCameraModel>();
    var activities = appModel.summary?.activities;
    if (activities == null) {
      return;
    }
    _timer?.cancel();
    if (_all) {
      lineModel.showAllRoutes();
      cameraModel.moveToDefault();
    } else {
      _timer = periodicImmediately(const Duration(seconds: 6), (t) {
        var activity = activities[Random().nextInt(activities.length)];
        cameraModel.moveToRoute(activity);
        lineModel.showRouteAnim(activity, durationMs: 4500, delayMs: 1000);
      });
    }
    _all = !_all;
  }
}
