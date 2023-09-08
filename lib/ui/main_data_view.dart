import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/map_camera_model.dart';
import '../model/map_lines_model.dart';

class MainDataView extends StatefulWidget {
  const MainDataView({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainDataViewState();
  }
}

class MainDataViewState extends State<MainDataView> {
  bool _all = false;

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
    if (_all) {
      lineModel.showAllRoutes();
      cameraModel.moveToDefault();
    } else {
      randomAnim() {
        var activity = activities[Random().nextInt(activities.length)];
        var duration = (activity.elapsedTime ?? 0) / 500;
        if (duration <= 1) {
          randomAnim();
          return;
        }
        cameraModel.moveToRoute(activity);
        lineModel.showRouteAnim(
          activity,
          durationMs: duration.toInt() * 1000,
          delayMs: 1000,
          onEnd: () {
            randomAnim();
          },
        );
      }

      randomAnim.call();
    }
    _all = !_all;
  }
}
