import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'package:liya/core/services/notification_service.dart';
import 'package:liya/core/services/dish_popularity_service.dart';

abstract class OrderRemoteDataSource {
  Future<void> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders(String phoneNumber);
  Future<OrderModel?> getOrderById(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;
  final NotificationService _notificationService = NotificationService();

  OrderRemoteDataSourceImpl({required this.firestore});

  FirebaseFirestore get firestoreInstance => firestore;

  @override
  Future<void> createOrder(OrderModel order) async {
    print('DEBUG - createOrder called with phone: ${order.phone}');

    final orderData = order.toJson();
    print('DEBUG - orderData after toJson: ${orderData['phone']}');

    // S'assurer que le champ phone est toujours présent dans Firestore
    if (!orderData.containsKey('phone')) {
      orderData['phone'] = order.phone;
      print('DEBUG - Added phone to orderData: ${orderData['phone']}');
    }

    print('DEBUG - Final orderData phone: ${orderData['phone']}');
    print('DEBUG - Saving to Firestore: $orderData');

    await firestore.collection('orders').doc(order.id).set(orderData);

    print('✅ Commande créée avec succès: ${order.id}');

    // 📊 Mettre à jour la popularité des plats commandés
    print('📊 Mise à jour de la popularité des plats...');
    for (final item in order.items) {
      try {
        // Pour chaque quantité commandée, incrémenter le compteur
        for (int i = 0; i < item.quantity; i++) {
          // Chercher l'ID du plat à partir du nom
          // Note: Idéalement, nous devrions avoir l'ID du plat dans OrderItemModel
          await _incrementDishPopularityByName(item.name);
        }
        print(
            '📊 Popularité mise à jour pour: ${item.name} (quantité: ${item.quantity})');
      } catch (e) {
        print('❌ Erreur mise à jour popularité pour ${item.name}: $e');
      }
    }

    // Envoyer notification aux admins
    print('📤 === DÉBUT ENVOI NOTIFICATION ADMIN ===');
    print('📤 OrderId: ${order.id}');
    print('📤 CustomerPhone: ${order.phone}');
    print('📤 Total: ${order.total}');
    print('📤 Items: ${order.items.length}');

    try {
      // Récupérer le nom de l'utilisateur depuis Firestore
      final userDoc =
          await firestore.collection('users').doc(order.phone).get();
      final userData = userDoc.data();
      final customerName = userData?['name'] as String? ?? 'Client';

      print('📤 CustomerName: $customerName');

      await _notificationService.notifyNewOrderToAdmin(
        orderId: order.id,
        customerName: customerName,
        total: order.total,
      );
      print('✅ Notification envoyée aux admins pour la commande: ${order.id}');
    } catch (e) {
      print('❌ Erreur envoi notification admin: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
    print('📤 === FIN ENVOI NOTIFICATION ADMIN ===');
  }

  /// Méthode helper pour incrémenter la popularité d'un plat par son nom
  Future<void> _incrementDishPopularityByName(String dishName) async {
    try {
      // Chercher le plat par son nom
      final dishQuery = await firestore
          .collection('dishes')
          .where('name', isEqualTo: dishName)
          .limit(1)
          .get();

      if (dishQuery.docs.isNotEmpty) {
        final dishId = dishQuery.docs.first.id;
        await DishPopularityService.incrementOrderCount(dishId);
        print('✅ Order count incrémenté pour le plat: $dishName (ID: $dishId)');
      } else {
        print('⚠️ Plat non trouvé dans la base: $dishName');
      }
    } catch (e) {
      print('❌ Erreur incrémentation popularité pour $dishName: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrders(String phoneNumber) async {
    final query = await firestore
        .collection('orders')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await firestore.collection('orders').doc(id).get();
    if (doc.exists) {
      return OrderModel.fromJson(doc.data()!);
    }
    return null;
  }
}
