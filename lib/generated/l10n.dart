// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `All`
  String get yearAll {
    return Intl.message(
      'All',
      name: 'yearAll',
      desc: '',
      args: [],
    );
  }

  /// `View Map`
  String get buttonViewMap {
    return Intl.message(
      'View Map',
      name: 'buttonViewMap',
      desc: '',
      args: [],
    );
  }

  /// `View Dashboard`
  String get buttonViewDashboard {
    return Intl.message(
      'View Dashboard',
      name: 'buttonViewDashboard',
      desc: '',
      args: [],
    );
  }

  /// `View Route Randomly`
  String get buttonStartRandom {
    return Intl.message(
      'View Route Randomly',
      name: 'buttonStartRandom',
      desc: '',
      args: [],
    );
  }

  /// `View All Routes`
  String get buttonViewRoutes {
    return Intl.message(
      'View All Routes',
      name: 'buttonViewRoutes',
      desc: '',
      args: [],
    );
  }

  /// `Summary of {year}`
  String summaryCardTitle(num year) {
    return Intl.message(
      'Summary of $year',
      name: 'summaryCardTitle',
      desc: '',
      args: [year],
    );
  }

  /// `Summary since {year}`
  String summaryCardTitleAll(num year) {
    return Intl.message(
      'Summary since $year',
      name: 'summaryCardTitleAll',
      desc: '',
      args: [year],
    );
  }

  /// `Running Summary`
  String get summaryCardTitleDefault {
    return Intl.message(
      'Running Summary',
      name: 'summaryCardTitleDefault',
      desc: '',
      args: [],
    );
  }

  /// `DISTANCE`
  String get summaryCardItemDistance {
    return Intl.message(
      'DISTANCE',
      name: 'summaryCardItemDistance',
      desc: '',
      args: [],
    );
  }

  /// `COUNTS`
  String get summaryCardItemCounts {
    return Intl.message(
      'COUNTS',
      name: 'summaryCardItemCounts',
      desc: '',
      args: [],
    );
  }

  /// `DURATION`
  String get summaryCardItemDuration {
    return Intl.message(
      'DURATION',
      name: 'summaryCardItemDuration',
      desc: '',
      args: [],
    );
  }

  /// `PACE`
  String get summaryCardItemAvgPace {
    return Intl.message(
      'PACE',
      name: 'summaryCardItemAvgPace',
      desc: '',
      args: [],
    );
  }

  /// `Running Activities`
  String get activitiesListCardTitle {
    return Intl.message(
      'Running Activities',
      name: 'activitiesListCardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Outdoor Running {distance}km`
  String activitiesListItemTitle(String distance) {
    return Intl.message(
      'Outdoor Running ${distance}km',
      name: 'activitiesListItemTitle',
      desc: '',
      args: [distance],
    );
  }

  /// `Duration {time} / Pace {pace}`
  String activitiesListItemSubTitle(String time, String pace) {
    return Intl.message(
      'Duration $time / Pace $pace',
      name: 'activitiesListItemSubTitle',
      desc: '',
      args: [time, pace],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
