import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../login_page.dart';
import 'signup_screen.dart';
import 'team_screen.dart';
import 'about_screen.dart';
import '../widgets/language_selector.dart';

class MainNavigationScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const MainNavigationScreen({
    super.key,
    required this.onLocaleChange,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('app.title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          LanguageSelector(onLocaleChange: onLocaleChange),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                localizations.translate('app.title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(localizations.translate('navigation.home')),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(localizations.translate('navigation.about')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(localizations.translate('navigation.team')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeamScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(localizations.translate('navigation.login')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(localizations.translate('navigation.signup')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const HomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations.translate('navigation.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: localizations.translate('navigation.profile'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: localizations.translate('navigation.settings'),
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }
}
