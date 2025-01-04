import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'signup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 48.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return _buildWideHeroContent(context, localizations);
                    }
                    return _buildNarrowHeroContent(context, localizations);
                  },
                ),
              ),
            ),

            // Features Section
            Container(
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
                  const SizedBox(height: 16),
                  Text(
                    localizations.translate('home.features.description'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _buildWideFeatureCards(context, localizations);
                      }
                      return _buildNarrowFeatureCards(context, localizations);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideHeroContent(BuildContext context, AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: _buildHeroText(context, localizations),
        ),
        Expanded(
          child: _buildHeroImage(),
        ),
      ],
    );
  }

  Widget _buildNarrowHeroContent(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        _buildHeroText(context, localizations),
        const SizedBox(height: 32),
        _buildHeroImage(),
      ],
    );
  }

  Widget _buildHeroText(BuildContext context, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('home.hero.title'),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          localizations.translate('home.hero.subtitle'),
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add, size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.translate('home.hero.signup'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        'https://img.freepik.com/free-vector/business-team-putting-together-jigsaw-puzzle-isolated-flat-vector-illustration-cartoon-partners-working-connection-teamwork-partnership-cooperation-concept_74855-9814.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildWideFeatureCards(BuildContext context, AppLocalizations localizations) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildFeatureCard(
          icon: Icons.show_chart,
          title: localizations.translate('home.features.management.title'),
          description: localizations.translate('home.features.management.description'),
        )),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(
          icon: Icons.task_alt,
          title: localizations.translate('home.features.organization.title'),
          description: localizations.translate('home.features.organization.description'),
        )),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(
          icon: Icons.analytics,
          title: localizations.translate('home.features.analytics.title'),
          description: localizations.translate('home.features.analytics.description'),
        )),
      ],
    );
  }

  Widget _buildNarrowFeatureCards(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.show_chart,
          title: localizations.translate('home.features.management.title'),
          description: localizations.translate('home.features.management.description'),
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: Icons.task_alt,
          title: localizations.translate('home.features.organization.title'),
          description: localizations.translate('home.features.organization.description'),
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: Icons.analytics,
          title: localizations.translate('home.features.analytics.title'),
          description: localizations.translate('home.features.analytics.description'),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
