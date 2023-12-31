import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../model/main_data_model.dart';
import '../model/map_data_model.dart';
import '../ui/main_data_view.dart';
import 'background_map_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appStateModel = context.watch<AppStateModel>();
    var summary = appStateModel.summary;
    var config = appStateModel.config;
    if (summary != null &&
        config != null &&
        summary.activities?.isNotEmpty == true) {
      return MultiProvider(
        providers: [
          ListenableProvider(create: (_) => MapDataModel(summary)),
          ListenableProvider(create: (_) => MapMarkerModel()),
          ListenableProvider(create: (_) => MainDataModel(summary)),
        ],
        child: const Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: BackgroundMapView(),
            ),
            MainDataView(),
          ],
        ),
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
