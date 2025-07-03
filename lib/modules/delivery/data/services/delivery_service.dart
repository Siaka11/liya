import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/delivery_user.dart';
import '../../domain/entities/delivery_order.dart';

class DeliveryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== GESTION DES LIVREURS =====

  // Récupérer un livreur par son numéro de téléphone
  static Future<DeliveryUser?> getDeliveryUserByPhone(
      String phoneNumber) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['role'] == 'livreur') {
          return DeliveryUser.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du livreur: $e');
      return null;
    }
  }

  // Mettre à jour la disponibilité d'un livreur
  static Future<void> updateDeliveryUserAvailability(
    String phoneNumber,
    bool isAvailable,
  ) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).update({
        'is_available': isAvailable,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la disponibilité: $e');
      rethrow;
    }
  }

  // Récupérer tous les livreurs disponibles
  static Future<List<DeliveryUser>> getAvailableDeliveryUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'livreur')
          .where('is_available', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des livreurs disponibles: $e');
      return [];
    }
  }

  // Mettre à jour les gains d'un livreur
  static Future<void> updateDeliveryUserEarnings(
    String phoneNumber,
    double newEarnings,
    int newCompletedDeliveries,
  ) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).update({
        'total_earnings': newEarnings,
        'completed_deliveries': newCompletedDeliveries,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour des gains: $e');
      rethrow;
    }
  }

  // ===== GESTION DES COMMANDES =====

  // Créer une nouvelle commande de livraison
  static Future<void> createDeliveryOrder(DeliveryOrder order) async {
    try {
      await _firestore
          .collection('delivery_orders')
          .doc(order.id)
          .set(order.toMap());
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      rethrow;
    }
  }

  // Récupérer les commandes en attente
  static Future<List<DeliveryOrder>> getPendingOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('delivery_orders')
          .where('status', isEqualTo: 'reception')
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryOrder.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes en attente: $e');
      return [];
    }
  }

  // Récupérer les commandes assignées à un livreur
  static Future<List<DeliveryOrder>> getOrdersForDeliveryUser(
      String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('delivery_orders')
          .where('delivery_phone_number', isEqualTo: phoneNumber)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryOrder.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes du livreur: $e');
      return [];
    }
  }

  // Assigner une commande à un livreur
  static Future<void> assignOrderToDeliveryUser(
    String orderId,
    String deliveryPhoneNumber,
    String deliveryName,
  ) async {
    try {
      await _firestore.collection('delivery_orders').doc(orderId).update({
        'delivery_phone_number': deliveryPhoneNumber,
        'delivery_name': deliveryName,
        'status': 'enRoute',
        'assigned_at': DateTime.now(),
      });
    } catch (e) {
      print('Erreur lors de l\'assignation de la commande: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut d'une commande
  static Future<void> updateOrderStatus(
    String orderId,
    DeliveryStatus status,
  ) async {
    try {
      final Map<String, dynamic> updateData = {'status': status.name};

      if (status == DeliveryStatus.livre) {
        updateData['completed_at'] = Timestamp.fromDate(DateTime.now());
      }

      await _firestore
          .collection('delivery_orders')
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }

  // Marquer une commande comme terminée et mettre à jour les gains
  static Future<void> completeOrder(
    String orderId,
    String deliveryPhoneNumber,
    double deliveryFee,
  ) async {
    try {
      // Mettre à jour le statut de la commande
      await updateOrderStatus(orderId, DeliveryStatus.livre);

      // Récupérer les informations actuelles du livreur
      final deliveryUser = await getDeliveryUserByPhone(deliveryPhoneNumber);
      if (deliveryUser != null) {
        final newEarnings = deliveryUser.totalEarnings + deliveryFee;
        final newCompletedDeliveries = deliveryUser.completedDeliveries + 1;

        // Mettre à jour les gains du livreur
        await updateDeliveryUserEarnings(
          deliveryPhoneNumber,
          newEarnings,
          newCompletedDeliveries,
        );
      }
    } catch (e) {
      print('Erreur lors de la finalisation de la commande: $e');
      rethrow;
    }
  }

  // Récupérer l'historique des commandes d'un livreur
  static Future<List<DeliveryOrder>> getDeliveryHistory(
      String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('delivery_orders')
          .where('delivery_phone_number', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'livre')
          .orderBy('completed_at', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryOrder.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // ===== STATISTIQUES =====

  // Calculer les gains du jour pour un livreur
  static Future<double> getTodayEarnings(String phoneNumber) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('delivery_orders')
          .where('delivery_phone_number', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'livre')
          .where('completed_at', isGreaterThanOrEqualTo: startOfDay)
          .where('completed_at', isLessThan: endOfDay)
          .get();

      double totalEarnings = 0;
      for (final doc in querySnapshot.docs) {
        final order = DeliveryOrder.fromMap(doc.data());
        totalEarnings += order.deliveryFee;
      }

      return totalEarnings;
    } catch (e) {
      print('Erreur lors du calcul des gains du jour: $e');
      return 0.0;
    }
  }

  // Calculer les gains de la semaine pour un livreur
  static Future<double> getWeekEarnings(String phoneNumber) async {
    try {
      final today = DateTime.now();
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfWeekDay =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      final querySnapshot = await _firestore
          .collection('delivery_orders')
          .where('delivery_phone_number', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'livre')
          .where('completed_at', isGreaterThanOrEqualTo: startOfWeekDay)
          .get();

      double totalEarnings = 0;
      for (final doc in querySnapshot.docs) {
        final order = DeliveryOrder.fromMap(doc.data());
        totalEarnings += order.deliveryFee;
      }

      return totalEarnings;
    } catch (e) {
      print('Erreur lors du calcul des gains de la semaine: $e');
      return 0.0;
    }
  }
}
