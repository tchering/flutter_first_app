import 'package:flutter/material.dart';

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
        onLocaleChange(Locale(value));
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
