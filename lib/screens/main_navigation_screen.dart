import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../login_page.dart';
import 'signup_screen.dart';
import 'team_screen.dart';
import 'about_screen.dart';
import '../widgets/language_selector.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const MainNavigationScreen({
    super.key,
    required this.onLocaleChange,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await ApiService.logout();
      setState(() {
        _userData = null;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('logout.success'.tr())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isLoggedIn = _userData != null;
    final bool isContractor = ApiService.isContractor(_userData);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_dost.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          LanguageSelector(
            onLocaleChange: widget.onLocaleChange,
            isDark: _currentIndex == 1,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(),
          if (isLoggedIn) DashboardScreen(isContractor: isContractor, fromNavBar: true),
          if (isLoggedIn) const MapScreen(),
          AboutScreen(),
          TeamScreen(),
          if (!isLoggedIn) LoginPage(),
          if (!isLoggedIn) SignupScreen(),
          if (isLoggedIn) ProfileScreen(),
          if (isLoggedIn) SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: tr('navigation.home'),
          ),
          if (isLoggedIn)
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: tr('navigation.dashboard'),
            ),
          if (isLoggedIn)
            const BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: tr('navigation.about'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: tr('navigation.team'),
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData != null 
                        ? '${_userData!['first_name']} ${_userData!['last_name']}'
                        : tr('app.title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  if (_userData != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _userData!['email'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _userData!['position'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(tr('navigation.home')),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            if (_userData == null) ...[
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(tr('navigation.about')),
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
                title: Text(tr('navigation.team')),
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
                title: Text(tr('navigation.login')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((_) => _loadUserData());
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: Text(tr('navigation.signup')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  ).then((_) => _loadUserData());
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: Text(tr('navigation.dashboard')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                        isContractor: ApiService.isContractor(_userData),
                        fromNavBar: false,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(tr('navigation.profile')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(tr('navigation.settings')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(tr('navigation.logout')),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
