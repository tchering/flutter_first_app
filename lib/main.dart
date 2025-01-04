import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en'),
      Locale('fr'),
    ],
    path: 'assets/translations', // Make sure this directory exists
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: tr('app.title'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/signup': (context) => const SignupScreen(),
      },
      home: MainNavigationScreen(
        onLocaleChange: (locale) {
          context.setLocale(locale);
        },
      ),
    );
  }
}
