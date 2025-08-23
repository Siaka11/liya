import 'dart:io';

class RecaptchaService {
  static RecaptchaService? _instance;

  // Clés reCAPTCHA Enterprise (vos vraies clés)
  static const String _androidSiteKey =
      '6LeizY0rAAAAAC4nTnbUBW1YJ8d0MttM1cjwR_0H'; // Votre clé Android
  static const String _iosSiteKey =
      '6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN'; // Votre clé iOS

  factory RecaptchaService() {
    _instance ??= RecaptchaService._internal();
    return _instance!;
  }

  RecaptchaService._internal();

  /// Initialise le service reCAPTCHA
  Future<void> initialize() async {
    try {
      final siteKey = Platform.isAndroid ? _androidSiteKey : _iosSiteKey;
      print(
          '🔐 Service reCAPTCHA initialisé avec clé: ${siteKey.substring(0, 10)}...');
      print('✅ Service reCAPTCHA prêt (mode simplifié)');
    } catch (e) {
      print('❌ Erreur initialisation reCAPTCHA: $e');
      rethrow;
    }
  }

  /// Simule l'exécution d'une action reCAPTCHA
  Future<String> execute(String action) async {
    try {
      print('🔐 Exécution reCAPTCHA action: $action');

      // Simulation d'un token reCAPTCHA
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final token = 'recaptcha_token_${action}_$timestamp';

      print('✅ Token reCAPTCHA simulé généré: ${token.substring(0, 20)}...');

      return token;
    } catch (e) {
      print('❌ Erreur exécution reCAPTCHA: $e');
      rethrow;
    }
  }

  /// Exécute une action de login
  Future<String> executeLogin() async {
    return execute('LOGIN');
  }

  /// Exécute une action de register
  Future<String> executeRegister() async {
    return execute('REGISTER');
  }

  /// Exécute une action personnalisée
  Future<String> executeCustom(String actionName) async {
    return execute(actionName);
  }

  /// Vérifie si le service est initialisé
  bool get isInitialized => true;

  /// Récupère la clé reCAPTCHA pour la plateforme actuelle
  String get currentSiteKey =>
      Platform.isAndroid ? _androidSiteKey : _iosSiteKey;
}
