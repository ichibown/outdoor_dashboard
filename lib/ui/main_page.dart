import 'package:flutter/material.dart';
import 'package:heatmap/ui/main_view.dart';
import 'package:heatmap/ui/mapbox_view.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: MapboxView(),
        ),
        MainView(),
      ],
    );
  }
}
