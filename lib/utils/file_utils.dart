import 'package:flutter/services.dart' show rootBundle;
import 'package:gpx/gpx.dart';

Future<String> loadTextAsset(String path) async {
  return await rootBundle.loadString(path);
}

Future<Gpx> loadGpxAsset(String path) async {
  var content = await loadTextAsset(path);
  return GpxReader().fromString(content);
}
