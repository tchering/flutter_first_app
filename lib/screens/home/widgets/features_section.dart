import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 48.0,
      ),
      child: Column(
        children: [
          Text(
            localizations.translate('home.features.title'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildWideLayout(context, localizations);
              }
              return _buildNarrowLayout(context, localizations);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, AppLocalizations localizations) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FeatureCard(
            icon: Icons.show_chart,
            title: localizations.translate('home.features.management.title'),
            description: localizations.translate('home.features.management.description'),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: FeatureCard(
            icon: Icons.task_alt,
            title: localizations.translate('home.features.organization.title'),
            description: localizations.translate('home.features.organization.description'),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: FeatureCard(
            icon: Icons.analytics,
            title: localizations.translate('home.features.analytics.title'),
            description: localizations.translate('home.features.analytics.description'),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        FeatureCard(
          icon: Icons.show_chart,
          title: localizations.translate('home.features.management.title'),
          description: localizations.translate('home.features.management.description'),
        ),
        const SizedBox(height: 24),
        FeatureCard(
          icon: Icons.task_alt,
          title: localizations.translate('home.features.organization.title'),
          description: localizations.translate('home.features.organization.description'),
        ),
        const SizedBox(height: 24),
        FeatureCard(
          icon: Icons.analytics,
          title: localizations.translate('home.features.analytics.title'),
          description: localizations.translate('home.features.analytics.description'),
        ),
      ],
    );
  }
}
