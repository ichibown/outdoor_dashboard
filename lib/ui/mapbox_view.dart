import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/map_camera_model.dart';
import '../model/map_lines_model.dart';
import '../utils/app_const.dart';

class MapboxView extends StatefulWidget {
  const MapboxView({super.key});

  @override
  State<StatefulWidget> createState() => _MapboxViewState();
}

class _MapboxViewState extends State<MapboxView> {
  late MapboxMapController _mapController;
  MapLinesModel get _linesModel => context.read<MapLinesModel>();
  MapCameraModel get _cameraModel => context.read<MapCameraModel>();
  AppStateModel get _appModel => context.read<AppStateModel>();
  // animating line placeholder.
  Line? _animatingLine;

  @override
  Widget build(BuildContext context) {
    var theme = context.watch<MapLinesModel>().theme;
    return MapboxMap(
      accessToken: _appModel.config?.mapboxToken ?? '',
      onMapCreated: _onMapCreated,
      styleString: theme.mapStyle,
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
    _linesModel.addListener(_onMapLinesUpdated);
    _cameraModel.addListener(_onMapCameraUpdated);
  }

  @override
  void dispose() {
    _linesModel.removeListener(_onMapLinesUpdated);
    _cameraModel.removeListener(_onMapCameraUpdated);
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;

    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = _onBrightnessChanged;
  }

  void _onBrightnessChanged() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _linesModel.changeTheme(brightness == Brightness.dark);
  }

  void _onMapStyleLoaded() async {
    _animatingLine ??= await _mapController.addLine(
      const LineOptions(geometry: []),
    );
    _linesModel.showAllRoutes();
    _cameraModel.moveToDefault();
  }

  void _onMapLinesUpdated() {
    var option = _linesModel.currentLineOptions;
    _mapController.removeLines(
      _mapController.lines.where((l) => l != _animatingLine),
    );
    if (option != null) {
      var line = _animatingLine;
      if (line != null) {
        _mapController.updateLine(line, option);
      }
    } else {
      _mapController.addLines(_linesModel.allLineOptions);
    }
  }

  void _onMapCameraUpdated() {
    _mapController.animateCamera(_cameraModel.cameraUpdate);
  }
}
