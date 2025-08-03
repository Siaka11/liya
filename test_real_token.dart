import 'dart:convert';
import 'package:http/http.dart' as http;

class RealTokenTester {
  static const String baseUrl =
      'https://us-central1-liya-a4a9f.cloudfunctions.net';
  static const String realFCMToken =
      "d9DU9HknRYOCmODahUKJk2:APA91bHdjnw4KJz0z-Wd3mr0xdqRaOyBVtB35O3ifWoQk9LT-sRSZhOkjTxwM90fJbDfM3-Yvd5E2nhdd1Ts8NcWWtwgoPIlQpVKeTG2VT3p_waXWRzssjw";

  /// Test complet avec le vrai token FCM
  static Future<void> testWithRealToken() async {
    print('🚀 Test avec le vrai token FCM...');
    print('📱 Token: ${realFCMToken.substring(0, 20)}...');

    // 1. Sauvegarder le vrai token
    print('\n📝 1. Sauvegarde du token FCM...');
    final updateResponse = await http.post(
      Uri.parse('$baseUrl/updateFCMToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': '+2250759128116',
        'fcm_token': realFCMToken,
      }),
    );

    print('Status: ${updateResponse.statusCode}');
    print('Response: ${updateResponse.body}');

    if (updateResponse.statusCode == 200) {
      print('✅ Token sauvegardé avec succès');

      // 2. Tester l'envoi de notification
      print('\n📤 2. Test envoi notification...');
      final notificationResponse = await http.post(
        Uri.parse('$baseUrl/sendNotification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '+2250759128116',
          'title': '🎉 Test Réussi !',
          'body': 'Le système de notifications fonctionne parfaitement !',
          'data': {
            'type': 'system_test',
            'timestamp': DateTime.now().toIso8601String(),
            'message': 'Test avec vrai token FCM',
          },
        }),
      );

      print('Status: ${notificationResponse.statusCode}');
      print('Response: ${notificationResponse.body}');

      if (notificationResponse.statusCode == 200) {
        print('✅ Notification envoyée avec succès !');
        print('📱 Vérifiez votre appareil pour voir la notification');
      } else {
        print('❌ Échec de l\'envoi de notification');
      }
    } else {
      print('❌ Échec de la sauvegarde du token');
    }
  }

  /// Test notification par rôle (admin)
  static Future<void> testNotificationToRole() async {
    print('\n👨‍💼 Test notification par rôle (admin)...');

    final response = await http.post(
      Uri.parse('$baseUrl/sendNotificationToRole'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'role': 'admin',
        'title': '🔔 Notification Admin',
        'body': 'Test de notification pour tous les admins',
        'data': {
          'type': 'admin_test',
          'timestamp': DateTime.now().toIso8601String(),
        },
      }),
    );

    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Notification par rôle envoyée');
    } else {
      print('❌ Échec notification par rôle');
    }
  }

  /// Test de toutes les fonctions
  static Future<void> runAllTests() async {
    print('🧪 Démarrage des tests complets...\n');

    await testWithRealToken();
    await testNotificationToRole();

    print('\n🎯 Tests terminés !');
    print('📱 Vérifiez votre appareil pour les notifications');
  }
}

void main() async {
  await RealTokenTester.runAllTests();
}
