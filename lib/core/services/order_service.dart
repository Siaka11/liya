import 'package:cloud_firestore/cloud_firestore.dart';
import 'dish_popularity_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée une nouvelle commande et met à jour la popularité des plats
  static Future<String?> createOrder({
    required String userId,
    required String userPhone,
    required List<Map<String, dynamic>> items, // {dishId, quantity, price}
    required String restaurantId,
    required double totalAmount,
    required String deliveryAddress,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🛒 Création d\'une nouvelle commande...');

      // 1. Créer la commande dans Firestore
      final orderData = {
        'user_id': userId,
        'user_phone': userPhone,
        'restaurant_id': restaurantId,
        'items': items,
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      final orderRef = await _firestore.collection('orders').add(orderData);
      final orderId = orderRef.id;

      print('✅ Commande créée avec l\'ID: $orderId');

      // 2. Mettre à jour la popularité de chaque plat commandé
      for (final item in items) {
        final dishId = item['dishId'] as String;
        final quantity = item['quantity'] as int;

        // Incrémenter le compteur pour chaque quantité
        for (int i = 0; i < quantity; i++) {
          await DishPopularityService.incrementOrderCount(dishId);
        }
      }

      print('✅ Popularité des plats mise à jour');

      return orderId;
    } catch (e) {
      print('❌ Erreur création commande: $e');
      return null;
    }
  }

  /// Met à jour la popularité d'un plat après commande (méthode legacy)
  static Future<void> incrementDishPopularity(String dishId) async {
    await DishPopularityService.incrementOrderCount(dishId);
  }

  /// À appeler quand un utilisateur passe une commande (méthode legacy)
  static Future<void> processOrder(List<String> dishIds, String userId) async {
    for (final dishId in dishIds) {
      await DishPopularityService.incrementOrderCount(dishId);
    }
  }

  /// Met à jour le statut d'une commande
  static Future<void> updateOrderStatus(
      String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('✅ Statut de la commande $orderId mis à jour: $newStatus');
    } catch (e) {
      print('❌ Erreur mise à jour statut commande: $e');
    }
  }

  /// Récupère les commandes d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return ordersSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('❌ Erreur récupération commandes utilisateur: $e');
      return [];
    }
  }
}
