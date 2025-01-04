import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../signup_screen.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 48.0,
      ),
      child: screenWidth > 800
          ? _buildWideContent(context)
          : _buildNarrowContent(context),
    );
  }

  Widget _buildWideContent(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildContent(context)),
        const SizedBox(width: 48),
        Expanded(child: _buildImage()),
      ],
    );
  }

  Widget _buildNarrowContent(BuildContext context) {
    return Column(
      children: [
        _buildContent(context),
        const SizedBox(height: 48),
        _buildImage(),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('home.hero.title'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          tr('home.hero.subtitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
        ),
        const SizedBox(height: 40),
        _buildSignUpButton(context),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 20,
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(tr('home.hero.signup')),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      'assets/images/hero.png',
      fit: BoxFit.contain,
    );
  }
}
