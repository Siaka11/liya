import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

void main() async {
  print('🚀 Test de récupération du token FCM...');

  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase initialisé');

    // Demander les permissions
    print('🔐 Demande des permissions...');
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('📊 Statut des permissions: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permissions accordées');

      // Récupérer le token
      print('🔑 Récupération du token FCM...');
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print('✅ Token FCM obtenu !');
        print('📱 Token complet: $token');
        print(
            '📱 Token (20 premiers caractères): ${token.substring(0, 20)}...');
      } else {
        print('❌ Token FCM est null');
      }
    } else {
      print('❌ Permissions refusées');
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }
}
