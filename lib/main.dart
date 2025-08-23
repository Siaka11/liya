import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:liya/core/services/notification_service.dart';
import 'core/singletons.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:liya/core/services/fcm_service.dart';
import 'package:liya/core/services/recaptcha_service.dart';

import 'app.dart';
import 'modules/home/presentation/pages/home_page.dart'; // Pour PromoPopupManager

// Handler pour les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print(
      '📱 Notification reçue en arrière-plan: ${message.notification?.title}');
}

// Handler pour les notifications en premier plan
void _handleForegroundMessage(RemoteMessage message) {
  print('📱 Notification reçue en premier plan: ${message.data}');

  // Afficher une notification locale si nécessaire
  if (message.notification != null) {
    // Vous pouvez afficher un SnackBar ou une notification locale ici
  }
}

// Handler pour les notifications en arrière-plan
void _handleBackgroundMessage(RemoteMessage message) {
  print('📱 Notification reçue en arrière-plan: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ⚡️ Activer App Check avec App Attest
  await FirebaseAppCheck.instance.activate(
    appleProvider: AppleProvider.appAttest, // ou deviceCheck si App Attest pas dispo
    webProvider: ReCaptchaV3Provider('6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN'),
  );

  // 🔐 Initialiser reCAPTCHA Enterprise
  try {
    await RecaptchaService().initialize();
    print('✅ reCAPTCHA Enterprise initialisé au démarrage');
  } catch (e) {
    print('⚠️ Erreur initialisation reCAPTCHA Enterprise: $e');
  }


  // Configurer Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialiser les singletons
  await initSingletons();

  // Forcer le nettoyage des verification_id au démarrage
  FirebaseAuthService().forceClearVerificationId();

  runApp(
      //Plugin for Internationalization i18n
      ProviderScope(
          child: EasyLocalization(
    useOnlyLangCode: true,
    supportedLocales: const [Locale('en'), Locale('fr')],
    path: 'assets/lang',
    fallbackLocale: const Locale('en', 'EN'),
    child: App(), // PromoPopupManager sera utilisé dans HomePage
  )));
}

Future<void> _configureFirebaseMessaging() async {
  try {
    // Configurer le handler pour les notifications en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Demander les permissions
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permissions FCM accordées');

      // Configurer les handlers de notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Récupérer le token FCM
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('📱 Token FCM: ${token.substring(0, 20)}...');
      }
    } else {
      print('❌ Permissions FCM refusées');
    }
  } catch (e) {
    print('❌ Erreur configuration FCM: $e');
  }
}
