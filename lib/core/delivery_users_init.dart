import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liya/modules/delivery/domain/entities/delivery_user.dart';

class DeliveryUsersInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeDeliveryUsers() async {
    try {
      // Liste des livreurs de test
      final deliveryUsers = [
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
        {
          'id': '0703456789',
          'phone_number': '0703456789',
          'name': 'Koné',
          'lastname': 'Moussa',
          'email': 'kone.moussa@example.com',
          'address': 'Marcory, Abidjan',
          'phone': '0703456789',
          'created_at': Timestamp.now(),
          'role': 'livreur',
          'is_available': false,
          'total_earnings': 18000.0,
          'completed_deliveries': 32,
          'rating': 4.2,
          'total_ratings': 28,
        },
        {
          'id': '0704567890',
          'phone_number': '0704567890',
          'name': 'Bamba',
          'lastname': 'Aminata',
          'email': 'bamba.aminata@example.com',
          'address': 'Plateau, Abidjan',
          'phone': '0704567890',
          'created_at': Timestamp.now(),
          'role': 'livreur',
          'is_available': true,
          'total_earnings': 28000.0,
          'completed_deliveries': 51,
          'rating': 4.6,
          'total_ratings': 48,
        },
        {
          'id': '0705678901',
          'phone_number': '0705678901',
          'name': 'Ouattara',
          'lastname': 'Sékou',
          'email': 'ouattara.sekou@example.com',
          'address': 'Adjamé, Abidjan',
          'phone': '0705678901',
          'created_at': Timestamp.now(),
          'role': 'livreur',
          'is_available': true,
          'total_earnings': 22000.0,
          'completed_deliveries': 38,
          'rating': 4.3,
          'total_ratings': 35,
        },
      ];

      // Insérer les livreurs dans Firestore
      for (final userData in deliveryUsers) {
        await _firestore
            .collection('users')
            .doc(userData['id'] as String)
            .set(userData);
        print('Livreur créé: ${userData['name']} ${userData['lastname']}');
      }

      print('✅ ${deliveryUsers.length} livreurs ont été créés avec succès!');
    } catch (e) {
      print('❌ Erreur lors de la création des livreurs: $e');
    }
  }

  static Future<void> createSampleDeliveryOrders() async {
    try {
      // Liste des commandes de test
      final deliveryOrders = [
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
        {
          'id': 'order_003',
          'customer_phone_number': '0703333333',
          'customer_name': 'Client Test 3',
          'customer_address': 'Marcory, Boulevard Latrille, Abidjan',
          'type': 'restaurant',
          'status': 'pending',
          'amount': 12000.0,
          'delivery_fee': 600.0,
          'description': 'Poulet braisé + Attieke + Sauce graine',
          'created_at': Timestamp.now(),
        },
        {
          'id': 'order_004',
          'customer_phone_number': '0704444444',
          'customer_name': 'Client Test 4',
          'customer_address': 'Plateau, Avenue Noguès, Abidjan',
          'type': 'parcel',
          'status': 'pending',
          'amount': 8000.0,
          'delivery_fee': 400.0,
          'description': 'Documents importants',
          'created_at': Timestamp.now(),
        },
        {
          'id': 'order_005',
          'customer_phone_number': '0705555555',
          'customer_name': 'Client Test 5',
          'customer_address': 'Adjamé, Rue 12, Abidjan',
          'type': 'restaurant',
          'status': 'pending',
          'amount': 9500.0,
          'delivery_fee': 500.0,
          'description': 'Thieboudienne + Bissap',
          'created_at': Timestamp.now(),
        },
      ];

      // Insérer les commandes dans Firestore
      for (final orderData in deliveryOrders) {
        await _firestore
            .collection('delivery_orders')
            .doc(orderData['id'] as String)
            .set(orderData);
        print('Commande créée: ${orderData['description']}');
      }

      print(
          '✅ ${deliveryOrders.length} commandes de test ont été créées avec succès!');
    } catch (e) {
      print('❌ Erreur lors de la création des commandes: $e');
    }
  }

  static Future<void> initializeAll() async {
    print('🚀 Initialisation du système de livraison...');
    await initializeDeliveryUsers();
    await createSampleDeliveryOrders();
    print('✅ Initialisation terminée!');
  }
}
