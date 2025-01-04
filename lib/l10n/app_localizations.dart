import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _translations = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<void> load() async {
    // Load common translations
    String commonJsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    _translations = json.decode(commonJsonString);

    // Load home translations
    try {
      String homeJsonString = await rootBundle.loadString(
        'assets/translations/home/${locale.languageCode}.json',
      );
      Map<String, dynamic> homeTranslations = json.decode(homeJsonString);
      _translations.addAll(homeTranslations);
    } catch (e) {
      print('Error loading home translations: $e');
    }

    // Load about translations
    try {
      String aboutJsonString = await rootBundle.loadString(
        'assets/translations/about/${locale.languageCode}.json',
      );
      Map<String, dynamic> aboutTranslations = json.decode(aboutJsonString);
      _translations.addAll(aboutTranslations);
    } catch (e) {
      print('Error loading about translations: $e');
    }
  }

  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _translations;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return the key if translation is not found
      }
    }

    return value.toString();
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
