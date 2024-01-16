import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/local.dart';
import '../../generated/l10n.dart';
import '../../model/app_state_model.dart';
import '../../model/main_data_model.dart';
import '../../model/map_data_model.dart';
import '../../utils/app_ext.dart';

class ActivitiesListCardView extends StatelessWidget {
  const ActivitiesListCardView({super.key});

  @override
  Widget build(BuildContext context) {
    var selectedYear = context
        .select<MainDataModel, YearSelectData>((value) => value.yearSelectData)
        .selectedYear;
    var list = context.read<MainDataModel>().activitiesByYear(selectedYear);
    var privacyMode =
        context.read<AppStateModel>().config?.privacyMode ?? false;
    if (list == null) {
      return const Placeholder();
    }
    if (privacyMode) {
      list.shuffle();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            S.current.activitiesListCardTitle,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: ListView.separated(
              itemCount: list.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, list[index], privacyMode),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.1,
                indent: 40,
                color: Theme.of(context).dividerColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context, OutdoorActivity activity, bool privacyMode) {
    var title = S.current.activitiesListItemTitle(
        (activity.totalDistance / 1000).toStringAsFixed(1));
    var subTitle =
        S.current.activitiesListItemSubTitle(activity.hms(), activity.pace());
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      leading: const Icon(
        Icons.directions_run,
        size: 24,
      ),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subTitle,
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Text(
        privacyMode
            ? activity.startDate().yyyyMM()
            : activity.startDate().yyyyMMdd(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      onTap: () {
        context.read<MainDataModel>().toggleExpanded();
        context
            .read<MapDataModel>()
            .showSingleRoute(activity, activity.animDurationSeconds() * 1000);
      },
    );
  }
}
