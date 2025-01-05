import 'app_localizations.dart';

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeTitle => 'Bienvenue sur MiniDost';

  @override
  String get welcomeDescription => 'Votre plateforme de confiance pour connecter les entrepreneurs et les sous-traitants';

  @override
  String get loginButtonText => 'Se connecter';

  @override
  String get signupButtonText => "S'inscrire";

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get loginError => 'Une erreur est survenue lors de la connexion. Veuillez réessayer.';

  @override
  String get invalidCredentials => 'Email ou mot de passe invalide';
}
