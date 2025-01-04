import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../signup_screen.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
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
              return _buildWideContent(context, localizations);
            }
            return _buildNarrowContent(context, localizations);
          },
        ),
      ),
    );
  }

  Widget _buildWideContent(BuildContext context, AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(child: _buildContent(context, localizations)),
        Expanded(child: _buildImage()),
      ],
    );
  }

  Widget _buildNarrowContent(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        _buildContent(context, localizations),
        const SizedBox(height: 32),
        _buildImage(),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations) {
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
        _buildSignUpButton(context, localizations),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context, AppLocalizations localizations) {
    return ElevatedButton(
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
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        'https://img.freepik.com/free-vector/business-team-putting-together-jigsaw-puzzle-isolated-flat-vector-illustration-cartoon-partners-working-connection-teamwork-partnership-cooperation-concept_74855-9814.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}
