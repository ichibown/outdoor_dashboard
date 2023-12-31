import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import '../data/local.dart';
import '../model/app_state_model.dart';
import '../model/map_data_model.dart';
import '../utils/app_const.dart';
import '../utils/app_ext.dart';
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
    return Stack(
      children: [
        MapboxMap(
          accessToken: appState.config?.mapboxToken ?? '',
          onMapCreated: _onMapCreated,
          styleString: _getMapStyle(),
          onCameraIdle: _onCameraIdle,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          doubleClickZoomEnabled: false,
          compassEnabled: false,
          scrollGesturesEnabled: true,
          myLocationEnabled: false,
          zoomGesturesEnabled: true,
          dragEnabled: false,
          onStyleLoadedCallback: _onMapStyleLoaded,
          initialCameraPosition:
              const CameraPosition(target: mapInitPos, zoom: 10),
        ),
        _MapMarker(),
      ],
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
    _mapController?.addListener(() {
      if (_mapController?.isCameraMoving == true) {
        _updateMarker();
      }
    });
  }

  void _onMapStyleLoaded() {
    context.read<MapDataModel>().showAllRoutes();
  }

  void _onCameraIdle() {
    _updateMarker();
  }

  void _onMapUpdated() async {
    var mapState = context.read<MapDataModel>().mapState;
    _animatingTimer?.cancel();
    _mapController?.removeLines(_mapController?.lines ?? []);
    _mapController?.removeCircles(_mapController?.circles ?? []);
    _mapController?.animateCamera(mapState.camera);
    context.read<MapMarkerModel>().updateMarker(null, null);
    if (mapState is SingleLineMap) {
      _showLineAnim(mapState);
    } else if (mapState is AllLinesMap) {
      _showAllLines(mapState);
    } else {
      // handle more states.
    }
  }

  void _showLineAnim(SingleLineMap mapState) async {
    var color = _getLineColor();
    var lineOptions = LineOptions(
      geometry: [],
      lineColor: _getLineColor(),
      lineWidth: _lineWidth,
      lineOpacity: _lineOpacity,
      draggable: false,
    );
    var line = await _mapController?.addLine(lineOptions);
    var circle = await _mapController?.addCircle(CircleOptions(
      circleRadius: 10,
      circleColor: color,
      geometry: mapState.linePoints.first,
    ));
    if (line == null || circle == null) {
      return;
    }
    var intervalMs = 10;
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
      lineOptions.geometry?.clear();
      lineOptions.geometry?.addAll(coords.sublist(0, end.floor()));
      end += step;
      _mapController?.updateLine(line, lineOptions);
      _mapController?.updateCircle(
          circle, CircleOptions(geometry: lineOptions.geometry?.lastOrNull));
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

  void _updateMarker() {
    var mapState = context.read<MapDataModel>().mapState;
    if (mapState is SingleLineMap) {
      _mapController?.toScreenLocation(mapState.startPos).then((value) {
        context.read<MapMarkerModel>().updateMarker(value, mapState.activity);
      });
    } else {
      context.read<MapMarkerModel>().updateMarker(null, null);
    }
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

class _MapMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mapMarker = context.watch<MapMarkerModel>();
    var privacyMode =
        context.read<AppStateModel>().config?.privacyMode ?? false;
    var point = mapMarker.markerPoint;
    var activity = mapMarker.activity;
    if (point == null || activity == null) {
      return Container();
    }
    var contentWidth = 150.0;
    var contentHeight = 74.0;
    return Positioned(
      left: point.x.toDouble() - contentWidth / 2,
      top: point.y.toDouble() - contentHeight - 20,
      child: CustomPaint(
        painter: _MarkerBackgroundPainter(
          Theme.of(context).colorScheme.background,
          Theme.of(context).colorScheme.primary,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: contentWidth,
          height: contentHeight,
          child: _buildMarkerContent(context, activity, privacyMode),
        ),
      ),
    );
  }

  Widget _buildMarkerContent(
      BuildContext context, OutdoorActivity activity, bool privacyMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_run,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              '${(activity.totalDistance / 1000).toStringAsFixed(1)}km',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(activity.hms(), style: Theme.of(context).textTheme.labelSmall),
            Text(activity.pace(),
                style: Theme.of(context).textTheme.labelSmall),
            Text(
              privacyMode
                  ? activity.startDate().yyyyMM()
                  : activity.startDate().yyyyMMdd(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        )
      ],
    );
  }
}

class _MarkerBackgroundPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _MarkerBackgroundPainter(this.color, this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 0.5
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    double triangleH = 20;
    double triangleW = 25.0;
    double width = size.width;
    double height = size.height;

    final Path trianglePath = Path()
      ..moveTo(width / 2 - triangleW / 2, height)
      ..lineTo(width / 2, triangleH + height)
      ..lineTo(width / 2 + triangleW / 2, height)
      ..lineTo(width / 2 - triangleW / 2, height);
    canvas.drawPath(trianglePath, paint);
    canvas.drawPath(trianglePath, borderPaint);
    final BorderRadius borderRadius = BorderRadius.circular(15);
    final Rect rect = Rect.fromLTRB(0, 0, width, height);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, paint);
    canvas.drawRRect(outer, borderPaint);
    borderPaint.color = color;
    borderPaint.strokeWidth = 1;
    canvas.drawLine(Offset(width / 2 + triangleW / 2, height),
        Offset(width / 2 - triangleW / 2, height), borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
