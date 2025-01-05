import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'signup_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('app.title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Gradient Background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[900]!,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? screenWidth * 0.1 : 24.0,
                    vertical: 48.0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _buildWideHeroContent(context);
                      }
                      return _buildNarrowHeroContent(context);
                    },
                  ),
                ),
              ),
            ),

            // Features Section
            Container(
              color: Colors.grey[50],
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? screenWidth * 0.1 : 24.0,
                vertical: 80.0,
              ),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            tr('home.features.title'),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr('home.features.description'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return _buildWideFeatureCards(context);
                      }
                      return _buildNarrowFeatureCards(context);
                    },
                  ),
                ],
              ),
            ),

            // Call to Action Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.green[600]!,
                    Colors.green[800]!,
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? screenWidth * 0.1 : 24.0,
                vertical: 64.0,
              ),
              child: Column(
                children: [
                  Text(
                    tr('home.call_to_action.title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr('home.call_to_action.description'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildCtaButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideHeroContent(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildHeroText(context),
        ),
        const SizedBox(width: 48),
        Expanded(
          child: _buildHeroImage(),
        ),
      ],
    );
  }

  Widget _buildNarrowHeroContent(BuildContext context) {
    return Column(
      children: [
        _buildHeroText(context),
        const SizedBox(height: 48),
        _buildHeroImage(),
      ],
    );
  }

  Widget _buildHeroText(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('home.hero.title'),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              tr('home.hero.subtitle'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 40),
            _buildCtaButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rocket_launch, size: 20),
          const SizedBox(width: 12),
          Text(
            tr('home.hero.signup'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            'https://img.freepik.com/free-vector/business-team-putting-together-jigsaw-puzzle-isolated-flat-vector-illustration-cartoon-partners-working-connection-teamwork-partnership-cooperation-concept_74855-9814.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWideFeatureCards(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildFeatureCard(
          icon: FontAwesomeIcons.chartLine,
          title: tr('home.features.management.title'),
          description: tr('home.features.management.description'),
          color: Colors.blue[700]!,
        )),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(
          icon: FontAwesomeIcons.listCheck,
          title: tr('home.features.organization.title'),
          description: tr('home.features.organization.description'),
          color: Colors.green[600]!,
        )),
        const SizedBox(width: 24),
        Expanded(child: _buildFeatureCard(
          icon: FontAwesomeIcons.chartPie,
          title: tr('home.features.analytics.title'),
          description: tr('home.features.analytics.description'),
          color: Colors.purple[600]!,
        )),
      ],
    );
  }

  Widget _buildNarrowFeatureCards(BuildContext context) {
    return Column(
      children: [
        _buildFeatureCard(
          icon: FontAwesomeIcons.chartLine,
          title: tr('home.features.management.title'),
          description: tr('home.features.management.description'),
          color: Colors.blue[700]!,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: FontAwesomeIcons.listCheck,
          title: tr('home.features.organization.title'),
          description: tr('home.features.organization.description'),
          color: Colors.green[600]!,
        ),
        const SizedBox(height: 24),
        _buildFeatureCard(
          icon: FontAwesomeIcons.chartPie,
          title: tr('home.features.analytics.title'),
          description: tr('home.features.analytics.description'),
          color: Colors.purple[600]!,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
