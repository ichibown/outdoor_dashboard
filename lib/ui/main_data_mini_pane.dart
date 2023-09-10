import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/main_data_model.dart';
import '../model/map_camera_model.dart';
import '../model/map_lines_model.dart';

class MiniActionButtonsView extends StatelessWidget {
  const MiniActionButtonsView({super.key});

  @override
  Widget build(BuildContext context) {
    var isRouteAnimating = context.watch<MapLinesModel>().isRouteAnimating;
    var actions = <IconData, Function>{
      Icons.dashboard_outlined: () {
        context.read<MainDataModel>().toggleExpanded();
      },
      isRouteAnimating ? Icons.stop_outlined : Icons.shuffle_outlined: () {
        _toggleMapRouteAnim(context);
      },
    };
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: actions.entries
            .map(
              (e) => IconButton(
                icon: Icon(e.key),
                onPressed: () => e.value.call(),
                iconSize: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
            .toList(),
      ),
    );
  }

  void _toggleMapRouteAnim(BuildContext context) {
    var appModel = context.read<AppStateModel>();
    var lineModel = context.read<MapLinesModel>();
    var cameraModel = context.read<MapCameraModel>();
    var activities = appModel.summary?.activities;
    if (activities == null) {
      return;
    }
    if (lineModel.isRouteAnimating) {
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
  }
}
