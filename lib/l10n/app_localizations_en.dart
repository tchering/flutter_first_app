import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to MiniDost';

  @override
  String get welcomeDescription => 'Your trusted platform for connecting contractors and subcontractors';

  @override
  String get loginButtonText => 'Login';

  @override
  String get signupButtonText => 'Sign Up';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginError => 'An error occurred during login. Please try again.';

  @override
  String get invalidCredentials => 'Invalid email or password';
}
