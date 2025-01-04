import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 48.0,
      ),
      child: Column(
        children: [
          Text(
            tr('home.features.title'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 48),
          screenWidth > 800
              ? _buildWideLayout(context)
              : _buildNarrowLayout(context),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FeatureCard(
            icon: Icons.show_chart,
            title: tr('home.features.management.title'),
            description: tr('home.features.management.description'),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: FeatureCard(
            icon: Icons.task_alt,
            title: tr('home.features.organization.title'),
            description: tr('home.features.organization.description'),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: FeatureCard(
            icon: Icons.analytics,
            title: tr('home.features.analytics.title'),
            description: tr('home.features.analytics.description'),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        FeatureCard(
          icon: Icons.show_chart,
          title: tr('home.features.management.title'),
          description: tr('home.features.management.description'),
        ),
        const SizedBox(height: 24),
        FeatureCard(
          icon: Icons.task_alt,
          title: tr('home.features.organization.title'),
          description: tr('home.features.organization.description'),
        ),
        const SizedBox(height: 24),
        FeatureCard(
          icon: Icons.analytics,
          title: tr('home.features.analytics.title'),
          description: tr('home.features.analytics.description'),
        ),
      ],
    );
  }
}
