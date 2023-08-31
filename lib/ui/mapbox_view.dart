import 'package:flutter/widgets.dart';
import 'package:heatmap/model/outdoor_data_store.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MapboxView extends StatefulWidget {
  const MapboxView({super.key});

  @override
  State<StatefulWidget> createState() => _MapboxViewState();
}

class _MapboxViewState extends State<MapboxView> {
  static const LatLng _centerPos = LatLng(39.913604, 116.411735);
  late MapboxMapController _mapController;
  late OutdoorDataModel _model;

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: getMapboxToken(),
      onMapCreated: _onMapCreated,
      styleString: _model.theme.mapStyle,
      onStyleLoadedCallback: _onMapStyleLoaded,
      initialCameraPosition: const CameraPosition(target: _centerPos, zoom: 11),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = context.read<OutdoorDataModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _onMapStyleLoaded() {
    _model.loadData().then((value) {
      _mapController.clearLines();
      for (var e in _model.polylineOptions) {
        _mapController.addLine(e);
      }
    });
  }
}
