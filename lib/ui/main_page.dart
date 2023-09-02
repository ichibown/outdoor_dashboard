import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/map_camera_model.dart';
import '../model/map_lines_model.dart';
import '../ui/main_data_view.dart';
import '../ui/mapbox_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appStateModel = context.watch<AppStateModel>();
    var summary = appStateModel.summary;
    var theme = appStateModel.theme;
    if (summary != null && summary.activities?.isNotEmpty == true) {
      return MultiProvider(
        providers: [
          ListenableProvider(create: (_) => MapLinesModel(summary, theme)),
          ListenableProvider(create: (_) => MapCameraModel()),
        ],
        child: const Stack(children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: MapboxView(),
          ),
          MainDataView(),
        ]),
      );
    } else {
      // loading data.
      context.read<AppStateModel>().loadData();
      return const Center(
        child: CircularProgressIndicator(strokeCap: StrokeCap.round),
      );
    }
  }
}
