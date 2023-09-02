import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;

import '../data/local.dart';
import '../utils/app_const.dart';
import '../utils/const.dart';

/// Model to store app data and state.
class AppStateModel extends ChangeNotifier {
  AppTheme _theme = lightTheme;
  AppTheme get theme => _theme;

  OutdoorSummary? _summary = null;
  OutdoorSummary? get summary => _summary;

  void loadData() async {
    String summaryJson = await rootBundle.loadString(
        path.join(assetsFolder, outdoorDataFolder, summaryFilePath));
    _summary = OutdoorSummary.fromJson(summaryJson);
    notifyListeners();
  }

  void changeTheme(AppTheme theme) {
    _theme = theme;
    notifyListeners();
  }
}
