import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageSelector extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  final bool isDark;

  const LanguageSelector({
    super.key,
    required this.onLocaleChange,
    this.isDark = false,
  });

  String _getFlagPath(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'assets/flags/gb.svg';
      case 'fr':
        return 'assets/flags/fr.svg';
      default:
        return 'assets/flags/fr.svg'; // Default to French flag
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: SvgPicture.asset(
        _getFlagPath(context.locale.languageCode),
        width: context.locale.languageCode == 'en' ? 27 : 24,
        height: 18,
        color: isDark ? Colors.white : null,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 180,
      ),
      onSelected: (String value) {
        final locale = Locale(value);
        context.setLocale(locale);
        onLocaleChange(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildLanguageMenuItem(
          context,
          'en',
          'English',
          'assets/flags/gb.svg',
        ),
        _buildLanguageMenuItem(
          context,
          'fr',
          'Français',
          'assets/flags/fr.svg',
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildLanguageMenuItem(
    BuildContext context,
    String languageCode,
    String languageName,
    String flagPath,
  ) {
    final isSelected = context.locale.languageCode == languageCode;

    return PopupMenuItem<String>(
      value: languageCode,
      height: 48,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SvgPicture.asset(
              flagPath,
              width: languageCode == 'en' ? 27 : 24,
              height: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languageName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
