import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationSystemTester {
  static const String baseUrl =
      'https://us-central1-liya-a4a9f.cloudfunctions.net';

  /// Test de la fonction updateFCMToken
  static Future<void> testUpdateFCMToken() async {
    print('🧪 Test de updateFCMToken...');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/updateFCMToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '+2250759128116',
          'fcm_token': 'test_token_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ updateFCMToken fonctionne');
      } else {
        print('❌ updateFCMToken échoue');
      }
    } catch (e) {
      print('❌ Erreur test updateFCMToken: $e');
    }
  }

  /// Test de la fonction sendNotification
  static Future<void> testSendNotification() async {
    print('\n🧪 Test de sendNotification...');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sendNotification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': '+2250759128116',
          'title': 'Test Notification',
          'body': 'Ceci est un test de notification système',
          'data': {
            'type': 'system_test',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ sendNotification fonctionne');
      } else {
        print('❌ sendNotification échoue');
      }
    } catch (e) {
      print('❌ Erreur test sendNotification: $e');
    }
  }

  /// Test de la fonction sendNotificationToRole
  static Future<void> testSendNotificationToRole() async {
    print('\n🧪 Test de sendNotificationToRole...');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sendNotificationToRole'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': 'admin',
          'title': 'Test Notification Admin',
          'body': 'Ceci est un test de notification pour les admins',
          'data': {
            'type': 'system_test',
            'timestamp': DateTime.now().toIso8601String(),
          },
        }),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ sendNotificationToRole fonctionne');
      } else {
        print('❌ sendNotificationToRole échoue');
      }
    } catch (e) {
      print('❌ Erreur test sendNotificationToRole: $e');
    }
  }

  /// Test de la fonction testFunction
  static Future<void> testTestFunction() async {
    print('\n🧪 Test de testFunction...');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/testFunction'),
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ testFunction fonctionne');
      } else {
        print('❌ testFunction échoue');
      }
    } catch (e) {
      print('❌ Erreur test testFunction: $e');
    }
  }

  /// Test complet du système
  static Future<void> runAllTests() async {
    print('🚀 Démarrage des tests du système de notifications...\n');

    await testTestFunction();
    await testUpdateFCMToken();
    await testSendNotification();
    await testSendNotificationToRole();

    print('\n🎯 Tests terminés !');
  }
}

void main() async {
  await NotificationSystemTester.runAllTests();
}
