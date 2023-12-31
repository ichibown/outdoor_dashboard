import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

import '../model/main_data_model.dart';
import 'cards/activities_list_card_view.dart';
import 'cards/summary_data_card_view.dart';
import 'main_data_content_full.dart';
import 'main_data_content_mini.dart';

class MainDataView extends StatelessWidget {
  const MainDataView({super.key});

  @override
  Widget build(BuildContext context) {
    var expanded =
        context.select<MainDataModel, bool>((value) => value.isExpanded);
    return Stack(
      children: [
        expanded ? PointerInterceptor(child: Container()) : Container(),
        Align(
          alignment: Alignment.center,
          child: AnimatedScale(
            scale: expanded ? 1 : 0,
            alignment: Alignment.bottomCenter,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            child: _buildFullView(context),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedScale(
            scale: expanded ? 0 : 1,
            alignment: Alignment.topCenter,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            child: _buildMiniView(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFullView(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LeftPaneView(),
            Container(
              height: LeftPaneView.height,
              padding: const EdgeInsets.all(24),
              child: const Wrap(
                direction: Axis.vertical,
                spacing: 24,
                runSpacing: 24,
                children: [
                  SummaryDataCardView(),
                  ActivitiesListCardView(),
                ],
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: const MiniActionButtonsView(),
      ),
    );
  }
}
