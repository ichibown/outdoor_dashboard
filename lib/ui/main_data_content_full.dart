import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../model/app_state_model.dart';
import '../model/main_data_model.dart';

class LeftPaneView extends StatelessWidget {
  static double get height =>
      UserInfoView._height +
      YearlyCountView._height +
      ActionButtonsView._height;

  const LeftPaneView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        UserInfoView(),
        YearlyCountView(),
        ActionButtonsView(),
      ],
    );
  }
}

class UserInfoView extends StatelessWidget {
  static const _height = 220.0;

  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    var config = context.read<AppStateModel>().config;
    var items = [
      const SizedBox(height: 32),
      CircleAvatar(
        radius: 40,
        backgroundColor: Theme.of(context).colorScheme.background,
        backgroundImage: NetworkImage(
          config?.avatar ?? "",
        ),
      ),
      const SizedBox(height: 16),
      Text(
        config?.title ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        config?.subTitle ?? "",
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontStyle: FontStyle.italic),
      ),
      Divider(
        height: 30,
        thickness: 0.2,
        indent: 12,
        color: Theme.of(context).dividerColor,
      ),
    ];
    return Container(
      width: 220,
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }
}

class YearlyCountView extends StatelessWidget {
  static const _height = 400.0;

  const YearlyCountView({super.key});

  @override
  Widget build(BuildContext context) {
    var yearSelectData = context
        .select<MainDataModel, YearSelectData>((value) => value.yearSelectData);
    var yearlyCounts = yearSelectData.yearlyCounts.entries.toList()
      ..sort((left, right) => right.key - left.key);
    var items = yearlyCounts
        .map((e) => GestureDetector(
            onTap: () => context.read<MainDataModel>().selectYear(e.key),
            child: Container(
              height: 48,
              width: 180,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: e.key == yearSelectData.selectedYear
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: _buildYearItem(
                  context, e.key, e.value, yearSelectData.selectedYear),
            )))
        .toList();
    return SizedBox(
      height: _height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  Widget _buildYearItem(
      BuildContext context, int year, int count, int selectedYear) {
    var textStyle = Theme.of(context).textTheme.titleMedium;
    var color = year == selectedYear
        ? Theme.of(context).colorScheme.secondaryContainer
        : textStyle?.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.brightness_1,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          year == YearSelectData.all ? S.current.yearAll : year.toString(),
          style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        )
      ],
    );
  }
}

class ActionButtonsView extends StatelessWidget {
  static const _height = 80.0;

  const ActionButtonsView({super.key});

  @override
  Widget build(BuildContext context) {
    var actions = <IconData, Function>{
      Icons.map_outlined: () {
        context.read<MainDataModel>().toggleExpanded();
      },
      Icons.language_outlined: () {
        // todo
      },
      Icons.dark_mode_outlined: () {
        // todo
      },
    };
    return SizedBox(
      height: _height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: actions.entries
            .map(
              (e) => IconButton(
                icon: Icon(e.key),
                onPressed: () => e.value.call(),
                iconSize: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
            .toList(),
      ),
    );
  }
}
