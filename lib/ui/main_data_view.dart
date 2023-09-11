import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

import '../model/main_data_model.dart';
import 'main_data_full_pane.dart';
import 'main_data_mini_pane.dart';

class MainDataView extends StatelessWidget {
  const MainDataView({super.key});

  @override
  Widget build(BuildContext context) {
    var expanded =
        context.select<MainDataModel, bool>((value) => value.isExpanded);
    return expanded
        ? Align(
            alignment: Alignment.center,
            child: PointerInterceptor(
              child: _buildFullView(context),
            ))
        : Align(
            alignment: Alignment.bottomCenter,
            child: _buildMiniView(context),
          );
  }

  Widget _buildFullView(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            LeftPaneView(),
            Container(
              width: 200,
              height: 200,
              child: Text("TODO"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniView(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: const MiniActionButtonsView(),
      ),
    );
  }
}

class MainDataMinView extends StatelessWidget {
  const MainDataMinView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
