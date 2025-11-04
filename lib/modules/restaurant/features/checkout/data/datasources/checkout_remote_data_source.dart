import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../card/data/models/cart_item_model.dart';
import '../../domain/entities/delivery_info.dart';
import '../models/delivery_info_model.dart';
import 'package:liya/core/services/notification_service.dart';
import 'package:liya/core/services/dish_popularity_service.dart';

abstract class CheckoutRemoteDataSource {
  Future<DeliveryInfo> getDeliveryInfo(String userId);
  Future<void> saveDeliveryInfo(String userId, DeliveryInfo deliveryInfo);
  Future<void> createOrder(
      String userId, List<CartItemModel> cartItems, DeliveryInfo deliveryInfo);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  @override
  Future<DeliveryInfo> getDeliveryInfo(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_info')
        .doc('current')
        .get();

    if (!doc.exists) {
      throw Exception('No delivery info found');
    }

    return DeliveryInfoModel.fromFirestore(doc.data()!);
  }

  @override
  Future<void> saveDeliveryInfo(
      String userId, DeliveryInfo deliveryInfo) async {
    if (deliveryInfo is! DeliveryInfoModel) {
      throw Exception('DeliveryInfo must be a DeliveryInfoModel');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_info')
        .doc('current')
        .set((deliveryInfo as DeliveryInfoModel).toFirestore());
  }

  @override
  Future<void> createOrder(
    String userId,
    List<CartItemModel> cartItems,
    DeliveryInfo deliveryInfo,
  ) async {
    if (deliveryInfo is! DeliveryInfoModel) {
      throw Exception('DeliveryInfo must be a DeliveryInfoModel');
    }

    final orderRef = _firestore.collection('orders').doc();
    final orderId = orderRef.id;
    final total = cartItems.fold(
        0.0,
        (sum, item) =>
            sum + (double.tryParse(item.price) ?? 0) * item.quantity);

    final batch = _firestore.batch();

    // Create order
    batch.set(orderRef, {
      'id': orderId,
      'userId': userId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'items': cartItems.map((item) => item.toFirestore()).toList(),
      'deliveryInfo': (deliveryInfo as DeliveryInfoModel).toFirestore(),
      'total': total,
    });

    // Execute batch
    await batch.commit();

    print('✅ Commande créée avec succès: $orderId');

    // 📊 Mettre à jour la popularité des plats commandés
    print('📊 Mise à jour de la popularité des plats...');
    for (final item in cartItems) {
      try {
        // Pour chaque quantité commandée, incrémenter le compteur
        for (int i = 0; i < item.quantity; i++) {
          // Chercher l'ID du plat à partir du nom
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
    print('📤 OrderId: $orderId');
    print('📤 CustomerPhone: $userId');
    print('📤 Total: $total');
    print('📤 Items: ${cartItems.length}');

    try {
      // Récupérer le nom de l'utilisateur depuis Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final customerName = userData?['name'] ?? 'Client';

      print('📤 CustomerName: $customerName');

      await _notificationService.notifyNewOrderToAdmin(
        orderId: orderId,
        customerName: customerName,
        total: total,
      );
      print('✅ Notification envoyée aux admins pour la commande: $orderId');
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
      final dishQuery = await _firestore
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
}
