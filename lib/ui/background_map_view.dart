import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/map_data_model.dart';
import '../utils/app_const.dart';
import '../utils/utils.dart';

class BackgroundMapView extends StatefulWidget {
  const BackgroundMapView({super.key});

  @override
  State<StatefulWidget> createState() => _BackgroundMapViewState();
}

class _BackgroundMapViewState extends State<BackgroundMapView> {
  static const _lineWidth = 7.0;
  static const _lineOpacity = 0.4;

  MapboxMapController? _mapController;
  Timer? _animatingTimer;

  @override
  Widget build(BuildContext context) {
    var appState = context.read<AppStateModel>();
    return MapboxMap(
      accessToken: appState.config?.mapboxToken ?? '',
      onMapCreated: _onMapCreated,
      styleString: _getMapStyle(),
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      doubleClickZoomEnabled: false,
      compassEnabled: false,
      scrollGesturesEnabled: true,
      myLocationEnabled: false,
      zoomGesturesEnabled: true,
      dragEnabled: false,
      onStyleLoadedCallback: _onMapStyleLoaded,
      initialCameraPosition: const CameraPosition(target: mapInitPos, zoom: 10),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<MapDataModel>().addListener(_onMapUpdated);
  }

  @override
  void dispose() {
    context.read<MapDataModel>().removeListener(_onMapUpdated);
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _onMapStyleLoaded() {
    context.read<MapDataModel>().showAllRoutes();
  }

  void _onMapUpdated() async {
    var mapState = context.read<MapDataModel>().mapState;
    _animatingTimer?.cancel();
    _mapController?.removeLines(_mapController?.lines ?? []);
    _mapController?.animateCamera(mapState.camera);
    if (mapState is SingleLineMap) {
      _showLineAnim(mapState);
    } else if (mapState is AllLinesMap) {
      _showAllLines(mapState);
    } else {
      // handle more states.
    }
  }

  void _showLineAnim(SingleLineMap mapState) async {
    var options = LineOptions(
      geometry: [],
      lineColor: _getLineColor(),
      lineWidth: _lineWidth,
      lineOpacity: _lineOpacity,
      draggable: false,
    );
    var line = await _mapController?.addLine(options);
    if (line == null) {
      return;
    }
    var intervalMs = 15;
    var coords = mapState.linePoints;
    var len = coords.length;
    var step = len / (mapState.durationMs * 1.0 / intervalMs);
    var start = 0;
    var end = start + step;
    _animatingTimer =
        periodicImmediately(Duration(milliseconds: intervalMs), (timer) {
      if (end > len) {
        timer.cancel();
        return;
      }
      options.geometry?.clear();
      options.geometry?.addAll(coords.sublist(0, end.floor()));
      end += step;
      _mapController?.updateLine(line, options);
    });
  }

  void _showAllLines(AllLinesMap mapState) {
    var color = _getLineColor();
    _mapController?.addLines(mapState.linePointsList
        .map(
          (e) => LineOptions(
            geometry: e,
            lineColor: color,
            lineWidth: _lineWidth,
            lineOpacity: _lineOpacity,
            draggable: false,
          ),
        )
        .toList());
  }

  String _getMapStyle() {
    var brightness = MediaQuery.of(context).platformBrightness;
    var config = context.read<AppStateModel>().config;
    return (brightness == Brightness.dark
            ? config?.mapStyleDark
            : config?.mapStyleLight) ??
        defaultTheme.mapStyle;
  }

  String _getLineColor() {
    var brightness = MediaQuery.of(context).platformBrightness;
    var config = context.read<AppStateModel>().config;
    return (brightness == Brightness.dark
            ? config?.mapLineColorDark
            : config?.mapLineColorLight) ??
        defaultTheme.mapLineColor;
  }
}
