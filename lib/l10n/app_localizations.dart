import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key) {
    switch (key) {
      case 'home.features.title':
        return 'Our Features';
      case 'home.features.description':
        return 'Discover what makes us unique';
      case 'home.hero.title':
        return welcomeTitle;
      case 'home.hero.subtitle':
        return welcomeDescription;
      case 'home.hero.signup':
        return signupButtonText;
      case 'home.features.management.title':
        return 'Project Management';
      case 'home.features.management.description':
        return 'Efficiently manage your construction projects';
      case 'home.features.organization.title':
        return 'Team Organization';
      case 'home.features.organization.description':
        return 'Organize your teams and tasks effectively';
      case 'home.features.analytics.title':
        return 'Analytics & Insights';
      case 'home.features.analytics.description':
        return 'Make data-driven decisions';
      default:
        return key;
    }
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  // Add your translation getters here
  String get welcomeTitle;
  String get welcomeDescription;
  String get loginButtonText;
  String get signupButtonText;
  String get emailHint;
  String get passwordHint;
  String get forgotPassword;
  String get loginError;
  String get invalidCredentials;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'fr':
        return AppLocalizationsFr();
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
