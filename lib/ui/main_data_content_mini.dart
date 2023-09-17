import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:outdoor_dashboard/utils/app_ext.dart';
import 'package:provider/provider.dart';

import '../data/local.dart';
import '../generated/l10n.dart';
import '../model/app_state_model.dart';
import '../model/main_data_model.dart';
import '../model/map_data_model.dart';
import '../utils/utils.dart';

class MiniActionButtonsView extends StatefulWidget {
  const MiniActionButtonsView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MiniActionButtonsViewState();
  }
}

class _MiniActionButtonsViewState extends State<MiniActionButtonsView> {
  Timer? _randomRouteTimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: _buildIcons(),
    );
  }

  @override
  void dispose() {
    _randomRouteTimer?.cancel();
    _randomRouteTimer = null;
    super.dispose();
  }

  Widget _buildIcons() {
    var activities = context.read<AppStateModel>().summary?.activities;
    var routeIcon = _randomRouteTimer != null
        ? Icons.stop_outlined
        : Icons.shuffle_outlined;
    var actions = <IconData, Function>{
      Icons.dashboard_outlined: () =>
          context.read<MainDataModel>().toggleExpanded(),
      routeIcon: () => _toggleRoute(activities),
    };
    return Row(
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
    );
  }

  void _toggleRoute(List<OutdoorActivity>? activities) {
    setState(() {
      if (_randomRouteTimer == null) {
        _randomRouteTimer = _startRandomRouteTimer(activities);
      } else {
        _randomRouteTimer?.cancel();
        _randomRouteTimer = null;
        context.read<MapDataModel>().showAllRoutes();
      }
    });
  }

  Timer? _startRandomRouteTimer(List<OutdoorActivity>? activities) {
    if (activities == null || activities.isEmpty) {
      return null;
    }
    var secondsPassed = 0;
    var duration = 0;
    return periodicImmediately(const Duration(seconds: 1), (timer) {
      if (secondsPassed >= duration) {
        OutdoorActivity activity =
            activities[Random().nextInt(activities.length)];
        duration = activity.animDurationSeconds();
        context.read<MapDataModel>().showSingleRoute(activity, duration * 1000);
        secondsPassed = 0;
      }
      secondsPassed++;
    });
  }
}
