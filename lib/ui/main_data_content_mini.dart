import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/local.dart';
import '../model/app_state_model.dart';
import '../model/main_data_model.dart';
import '../model/map_data_model.dart';
import '../utils/utils.dart';

class MiniActionButtonsView extends StatefulWidget {
  const MiniActionButtonsView({super.key});

  @override
  State<StatefulWidget> createState() {
    return MiniActionButtonsViewState();
  }
}

class MiniActionButtonsViewState extends State<MiniActionButtonsView> {
  Timer? _randomRouteTimer;

  @override
  Widget build(BuildContext context) {
    var activities = context.read<AppStateModel>().summary?.activities;
    var routeIcon = _randomRouteTimer != null
        ? Icons.stop_outlined
        : Icons.shuffle_outlined;
    var actions = <IconData, Function>{
      Icons.dashboard_outlined: () =>
          context.read<MainDataModel>().toggleExpanded(),
      routeIcon: () => _toggleRoute(activities),
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

  void _toggleRoute(List<OutdoorActivity>? activities) {
    setState(() {
      if (_randomRouteTimer == null) {
        _randomRouteTimer = _startRandomRouteTimer(activities);
      } else {
        context.read<MapDataModel>().showAllRoutes();
        _randomRouteTimer?.cancel();
        _randomRouteTimer = null;
      }
    });
  }

  Timer? _startRandomRouteTimer(List<OutdoorActivity>? activities) {
    if (activities == null || activities.isEmpty) {
      return null;
    }
    // one more second before and after route anim.
    var animMinSecond = 5;
    var secondsPassed = 0;
    var duration = 0;
    return periodicImmediately(const Duration(seconds: 1), (timer) {
      if (secondsPassed >= duration) {
        OutdoorActivity activity =
            activities[Random().nextInt(activities.length)];
        duration = (activity.elapsedTime ?? 0) ~/ 500;
        duration = duration <= animMinSecond ? animMinSecond : duration;
        context.read<MapDataModel>().showSingleRoute(activity, duration * 1000);
        secondsPassed = 0;
      }
      secondsPassed++;
    });
  }
}
