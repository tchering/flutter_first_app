import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const LanguageSelector({
    super.key,
    required this.onLocaleChange,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String value) {
        final locale = Locale(value);
        context.setLocale(locale);
        onLocaleChange(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('🇬🇧'), // English flag emoji
              SizedBox(width: 10),
              Text('English'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              Text('🇫🇷'), // French flag emoji
              SizedBox(width: 10),
              Text('Français'),
            ],
          ),
        ),
      ],
    );
  }
}
