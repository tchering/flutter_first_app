import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/language_selector.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'about.title'.tr(),
          style: const TextStyle(fontSize: 20),
        ),
        elevation: 0,
        actions: [
          LanguageSelector(
            onLocaleChange: (locale) => context.setLocale(locale),
            isDark: true,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16.0 : screenWidth * 0.1,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mission Section
              Text(
                'mission.title'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'mission.description'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 40),

              // Solutions Section
              Text(
                'solution.title'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildFeatureItem(
                    context,
                    icon: Icons.business,
                    translationPrefix: 'solution.management',
                    color: Colors.blue,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.support_agent,
                    translationPrefix: 'solution.support',
                    color: Colors.green,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.location_on,
                    translationPrefix: 'solution.location',
                    color: Colors.orange,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.attach_money,
                    translationPrefix: 'solution.finance',
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Call to Action Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Text(
                      'solution.cta.title'.tr(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      icon: const Icon(Icons.rocket_launch),
                      label: Text(
                        'solution.cta.button'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String translationPrefix,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: isSmallScreen ? double.infinity : 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            tr('$translationPrefix.title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('$translationPrefix.description'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}
