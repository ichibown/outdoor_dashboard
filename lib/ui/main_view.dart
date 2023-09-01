import 'package:flutter/material.dart';
import 'package:heatmap/model/outdoor_data_store.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: IconButton(
        iconSize: 72,
        onPressed: () {
          context.read<OutdoorDataModel>().toggleState();
        },
        icon: const Icon(Icons.map_sharp),
      ),
    );
  }
}
