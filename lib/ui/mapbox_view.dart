import 'package:flutter/widgets.dart';
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
  late Line _animatingLine;

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: _appModel.config?.mapboxToken ?? '',
      onMapCreated: _onMapCreated,
      styleString: _appModel.theme.mapStyle,
      tiltGesturesEnabled: false,
      onStyleLoadedCallback: _onMapStyleLoaded,
      initialCameraPosition: const CameraPosition(target: mapInitPos, zoom: 10),
    );
  }

  @override
  void initState() {
    super.initState();
    _linesModel.addListener(_onMapLinesUpdated);
    _cameraModel.addListener(_onMapCameraUpdated);
    _appModel.addListener(_onAppStateUpdated);
  }

  @override
  void dispose() {
    _linesModel.removeListener(_onMapLinesUpdated);
    _cameraModel.removeListener(_onMapCameraUpdated);
    _appModel.removeListener(_onAppStateUpdated);
    super.dispose();
  }

  void _onAppStateUpdated() {
    _linesModel.changeTheme(_appModel.theme);
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _onMapStyleLoaded() async {
    _animatingLine = await _mapController.addLine(
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
      _mapController.updateLine(_animatingLine, option);
    } else {
      _mapController.addLines(_linesModel.allLineOptions);
    }
  }

  void _onMapCameraUpdated() {
    _mapController.animateCamera(_cameraModel.cameraUpdate);
  }
}
