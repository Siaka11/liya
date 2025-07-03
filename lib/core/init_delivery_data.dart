import 'package:cloud_firestore/cloud_firestore.dart';

class InitDeliveryData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeDeliverySystem() async {
    try {
      print('🚀 Initialisation du système de livraison...');

      // Créer des livreurs de test
      await _createDeliveryUsers();

      // Créer des commandes de test
      await _createSampleOrders();

      print('✅ Système de livraison initialisé avec succès!');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
    }
  }

  static Future<void> _createDeliveryUsers() async {
    final users = [
      {
        'id': '0701234567',
        'phone_number': '0701234567',
        'name': 'Kouassi',
        'lastname': 'Jean',
        'email': 'kouassi.jean@example.com',
        'address': 'Cocody, Abidjan',
        'phone': '0701234567',
        'created_at': Timestamp.now(),
        'role': 'livreur',
        'is_available': true,
        'total_earnings': 25000.0,
        'completed_deliveries': 45,
        'rating': 4.5,
        'total_ratings': 42,
      },
      {
        'id': '0702345678',
        'phone_number': '0702345678',
        'name': 'Traoré',
        'lastname': 'Fatou',
        'email': 'traore.fatou@example.com',
        'address': 'Yopougon, Abidjan',
        'phone': '0702345678',
        'created_at': Timestamp.now(),
        'role': 'livreur',
        'is_available': true,
        'total_earnings': 32000.0,
        'completed_deliveries': 58,
        'rating': 4.8,
        'total_ratings': 55,
      },
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user['id'] as String).set(user);
      print('✅ Livreur créé: ${user['name']} ${user['lastname']}');
    }
  }

  static Future<void> _createSampleOrders() async {
    final orders = [
      {
        'id': 'order_001',
        'customer_phone_number': '0701111111',
        'customer_name': 'Client Test 1',
        'customer_address': 'Cocody, Rue des Jardins, Abidjan',
        'type': 'restaurant',
        'status': 'pending',
        'amount': 8500.0,
        'delivery_fee': 500.0,
        'description': 'Pizza Margherita + 2 boissons',
        'created_at': Timestamp.now(),
      },
      {
        'id': 'order_002',
        'customer_phone_number': '0702222222',
        'customer_name': 'Client Test 2',
        'customer_address': 'Yopougon, Rue du Commerce, Abidjan',
        'type': 'parcel',
        'status': 'pending',
        'amount': 15000.0,
        'delivery_fee': 800.0,
        'description': 'Colis fragile - Électronique',
        'created_at': Timestamp.now(),
      },
    ];

    for (final order in orders) {
      await _firestore
          .collection('delivery_orders')
          .doc(order['id'] as String)
          .set(order);
      print('✅ Commande créée: ${order['description']}');
    }
  }
}
