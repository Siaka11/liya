import 'dart:convert';
import 'package:http/http.dart' as http;

// Test des notifications pour les colis
void main() async {
  print('🧪 === TEST NOTIFICATIONS COLIS ===');

  // URL de la Firebase Function
  const String baseUrl = 'https://us-central1-liya-a4a9f.cloudfunctions.net';
  const String sendNotificationUrl = '$baseUrl/sendNotification';
  const String sendNotificationToRoleUrl = '$baseUrl/sendNotificationToRole';

  // Test 1: Notification nouveau colis aux admins
  print('\n📦 Test 1: Notification nouveau colis aux admins');
  try {
    final response = await http.post(
      Uri.parse(sendNotificationToRoleUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'role': 'admin',
        'title': '📦 Nouveau colis reçu',
        'body': 'Colis #COLIS20250728173223 de Client Test - 1500 FCFA',
        'data': {
          'type': 'new_parcel',
          'parcel_id': 'COLIS20250728173223',
          'sender_name': 'Client Test',
          'total': '1500',
        },
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Notification nouveau colis envoyée: ${result['message']}');
    } else {
      print('❌ Erreur notification nouveau colis: ${response.statusCode}');
      print('Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur test notification nouveau colis: $e');
  }

  // Test 2: Notification colis assigné au livreur
  print('\n🚚 Test 2: Notification colis assigné au livreur');
  try {
    final response = await http.post(
      Uri.parse(sendNotificationUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': '+2250140095584', // Numéro de test
        'title': '📦 Nouveau colis à livrer',
        'body': 'Colis #COLIS20250728173223 - De: Yamoussoukro → À: Abidjan',
        'data': {
          'type': 'parcel_assigned',
          'parcel_id': 'COLIS20250728173223',
          'sender_address': 'De: Yamoussoukro → À: Abidjan',
          'total': '1500',
        },
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Notification colis assigné envoyée: ${result['message']}');
    } else {
      print('❌ Erreur notification colis assigné: ${response.statusCode}');
      print('Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur test notification colis assigné: $e');
  }

  // Test 3: Notification statut livraison colis
  print('\n📱 Test 3: Notification statut livraison colis');
  try {
    final response = await http.post(
      Uri.parse(sendNotificationUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': '+2250140095584', // Numéro de test
        'title': '🚚 Livraison commencée',
        'body':
            'Votre colis #COLIS20250728173223 est en cours de livraison par Jean Dupont',
        'data': {
          'type': 'delivery_status',
          'order_id': 'COLIS20250728173223',
          'status': 'started',
          'delivery_user': 'Jean Dupont',
        },
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('✅ Notification statut livraison envoyée: ${result['message']}');
    } else {
      print('❌ Erreur notification statut livraison: ${response.statusCode}');
      print('Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur test notification statut livraison: $e');
  }

  print('\n🎯 === FIN TESTS NOTIFICATIONS COLIS ===');
}
