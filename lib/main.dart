import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/app_state_model.dart';
import '../ui/main_page.dart';
import 'generated/l10n.dart';

void main() {
  runApp(const HeatmapApp());
}

class HeatmapApp extends StatelessWidget {
  const HeatmapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateModel(),
      child: MaterialApp(
        title: 'Outdoor Heatmap (Working in Progress)',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            // ···
            titleLarge: TextStyle(
              fontSize: 30,
              fontStyle: FontStyle.italic,
            ),
            bodyMedium: TextStyle(),
            displaySmall: TextStyle(),
          ),
        ),
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        home: const MainPage(),
      ),
    );
  }
}
