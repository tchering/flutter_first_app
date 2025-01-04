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
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: const [
              Text('🇬🇧'), // English flag emoji
              SizedBox(width: 10),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: const [
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
