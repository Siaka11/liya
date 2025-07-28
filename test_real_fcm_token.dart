import 'dart:convert';
import 'package:http/http.dart' as http;

class RealFCMTokenTester {
  static const String baseUrl =
      'https://us-central1-liya-a4a9f.cloudfunctions.net';

  /// Test avec un vrai token FCM (à remplacer par un vrai token)
  static Future<void> testWithRealToken() async {
    // Remplacez ceci par un vrai token FCM de votre appareil
    const String realFCMToken = "REPLACE_WITH_REAL_FCM_TOKEN";

    if (realFCMToken == "REPLACE_WITH_REAL_FCM_TOKEN") {
      print('❌ Veuillez remplacer REAL_FCM_TOKEN par un vrai token FCM');
      print('📱 Pour obtenir un vrai token FCM :');
      print('   1. Lancez l\'application sur votre appareil');
      print('   2. Connectez-vous');
      print('   3. Vérifiez les logs pour voir le token FCM');
      print('   4. Remplacez REAL_FCM_TOKEN dans ce script');
      return;
    }

    print('🧪 Test avec un vrai token FCM...');

    // 1. Sauvegarder le vrai token
    final updateResponse = await http.post(
      Uri.parse('$baseUrl/updateFCMToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': '+2250759128116',
        'fcm_token': realFCMToken,
      }),
    );

    print('Update Token Status: ${updateResponse.statusCode}');
    print('Update Token Response: ${updateResponse.body}');

    if (updateResponse.statusCode == 200) {
      // 2. Tester l'envoi de notification
      final notificationResponse = await http.post(
        Uri.parse('$baseUrl/sendNotification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '+2250759128116',
          'title': 'Test Vrai Token',
          'body': 'Ceci est un test avec un vrai token FCM !',
          'data': {
            'type': 'system_test',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      print('Notification Status: ${notificationResponse.statusCode}');
      print('Notification Response: ${notificationResponse.body}');

      if (notificationResponse.statusCode == 200) {
        print('✅ Notification envoyée avec succès !');
      } else {
        print('❌ Échec de l\'envoi de notification');
      }
    }
  }
}

void main() async {
  await RealFCMTokenTester.testWithRealToken();
}
