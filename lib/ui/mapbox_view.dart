import 'package:flutter/widgets.dart';
import 'package:heatmap/model/outdoor_data_store.dart';
import 'package:heatmap/utils/app_const.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MapboxView extends StatefulWidget {
  const MapboxView({super.key});

  @override
  State<StatefulWidget> createState() => _MapboxViewState();
}

class _MapboxViewState extends State<MapboxView> {
  late MapboxMapController _mapController;
  late OutdoorDataModel _model;
  Line? _currentLine;
  LineOptions? _currentOption;

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: getMapboxToken(),
      onMapCreated: _onMapCreated,
      styleString: _model.theme.mapStyle,
      tiltGesturesEnabled: false,
      onStyleLoadedCallback: _onMapStyleLoaded,
      initialCameraPosition: const CameraPosition(target: mapInitPos, zoom: 11),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = context.read<OutdoorDataModel>();
    _model.addListener(_onModelUpdated);
  }

  @override
  void dispose() {
    _model.removeListener(_onModelUpdated);
    super.dispose();
  }

  void _onModelUpdated() {
    switch (_model.lineState) {
      case PolylineState.none:
        _mapController.clearLines();
        break;
      case PolylineState.all:
        _currentLine = null;
        _currentOption = null;
        _showAllLines();
        break;
      case PolylineState.single:
        _showAnimatingLine();
      default:
        break;
    }

    var bounds = _model.cameraBounds;
    _mapController.moveCamera(
      CameraUpdate.newLatLngBounds(bounds,
          left: 20, top: 20, right: 20, bottom: 20),
    );
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _onMapStyleLoaded() {
    _model.loadData().then((value) => _model.randomRoute());
  }

  void _showAllLines() {
    if (_model.allLines.isNotEmpty) {
      _mapController.clearLines();
      _mapController.addLines(_model.allLines
          .map((e) => LineOptions(
                geometry: e,
                lineColor: _model.theme.mapPolylineColorHex,
                lineWidth: 8.0,
                lineOpacity: 0.3,
                draggable: false,
              ))
          .toList());
    }
  }

  void _showAnimatingLine() {
    var line = _currentLine;
    var option = _currentOption;
    if (line == null || option == null) {
      option = LineOptions(
        geometry: [],
        lineColor: _model.theme.mapPolylineColorHex,
        lineWidth: 10.0,
        lineOpacity: 0.6,
        draggable: false,
      );
      _mapController.addLine(option).then((line) {
        _currentLine = line;
        _currentOption = option;
      });
    } else {
      option.geometry?.clear();
      option.geometry?.addAll(_model.animatingLine);
      _mapController.updateLine(line, option);
    }
  }
}
