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
    _translations = {};

    // Load about translations first
    try {
      String aboutJsonString = await rootBundle.loadString(
        'assets/translations/about/${locale.languageCode}.json',
      );
      print('About translations loaded: $aboutJsonString'); // Debug print
      _translations = json.decode(aboutJsonString);
    } catch (e) {
      print('Error loading about translations: $e');
    }

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

    // Load common translations last
    try {
      String commonJsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json',
      );
      Map<String, dynamic> commonTranslations = json.decode(commonJsonString);
      _translations.addAll(commonTranslations);
    } catch (e) {
      print('Error loading common translations: $e');
    }

    print('Final translations: $_translations'); // Debug print
  }

  String translate(String key) {
    print('Translating key: $key'); // Debug print
    print('Available translations: $_translations'); // Debug print
    
    List<String> keys = key.split('.');
    dynamic value = _translations;

    for (String k in keys) {
      print('Looking up key: $k in $value'); // Debug print
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        print('Translation not found for key: $key'); // Debug print
        return key;
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
