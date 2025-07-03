import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/delivery_user.dart';
import '../../domain/entities/delivery_order.dart';

class DeliveryExistingService {
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
        'active': isAvailable,
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
          .where('active', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DeliveryUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des livreurs disponibles: $e');
      return [];
    }
  }

  // ===== GESTION DES COMMANDES RESTAURANT =====

  // Récupérer les commandes restaurant en attente de livraison
  static Future<List<DeliveryOrder>> getPendingRestaurantOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'reception')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['customer_name'] ?? 'Client',
          customerAddress: data['address'] ?? '',
          type: DeliveryType.restaurant,
          status: DeliveryStatus.reception,
          amount: (data['subtotal'] ?? 0.0).toDouble(),
          deliveryFee: (data['deliveryFee'] ?? 500.0).toDouble(),
          description:
              data['items']?.map((item) => item['name'] ?? '').join(', ') ??
                  'Commande restaurant',
          createdAt: data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes restaurant: $e');
      return [];
    }
  }

  // Assigner une commande restaurant à un livreur
  static Future<void> assignRestaurantOrderToDeliveryUser(
    String orderId,
    String deliveryPhoneNumber,
    String deliveryName,
  ) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'delivery_phone': deliveryPhoneNumber,
        'delivery_name': deliveryName,
        'status': 'enRoute',
        'assigned_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de l\'assignation de la commande restaurant: $e');
      rethrow;
    }
  }

  // ===== GESTION DES COLIS =====

  // Récupérer les colis en attente de livraison
  static Future<List<DeliveryOrder>> getPendingParcelOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('parcels')
          .where('status', isEqualTo: 'reception')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['receiverName'] ?? '',
          customerAddress: data['address'] ?? '',
          type: DeliveryType.parcel,
          status: DeliveryStatus.reception,
          amount: (data['prix'] ?? 0.0).toDouble(),
          deliveryFee: 800.0, // Frais de livraison fixe pour les colis
          description: data['instructions'] ?? 'Colis',
          createdAt: data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des colis: $e');
      return [];
    }
  }

  // Assigner un colis à un livreur
  static Future<void> assignParcelToDeliveryUser(
    String parcelId,
    String deliveryPhoneNumber,
    String deliveryName,
  ) async {
    try {
      await _firestore.collection('parcels').doc(parcelId).update({
        'delivery_phone': deliveryPhoneNumber,
        'delivery_name': deliveryName,
        'status': 'enRoute',
        'assigned_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de l\'assignation du colis: $e');
      rethrow;
    }
  }

  // ===== COMMANDES ASSIGNÉES À UN LIVREUR =====

  // Récupérer les commandes restaurant assignées à un livreur
  static Future<List<DeliveryOrder>> getRestaurantOrdersForDeliveryUser(
      String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('delivery_phone', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'enRoute')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['customer_name'] ?? 'Client',
          customerAddress: data['address'] ?? '',
          deliveryPhoneNumber: data['delivery_phone'],
          deliveryName: data['delivery_name'],
          type: DeliveryType.restaurant,
          status: _mapOrderStatus(data['status']),
          amount: (data['subtotal'] ?? 0.0).toDouble(),
          deliveryFee: (data['deliveryFee'] ?? 500.0).toDouble(),
          description:
              data['items']?.map((item) => item['name'] ?? '').join(', ') ??
                  'Commande restaurant',
          createdAt: data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
          assignedAt: data['assigned_at'] is String
              ? DateTime.parse(data['assigned_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      print(
          'Erreur lors de la récupération des commandes restaurant du livreur: $e');
      return [];
    }
  }

  // Récupérer les colis assignés à un livreur
  static Future<List<DeliveryOrder>> getParcelOrdersForDeliveryUser(
      String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('parcels')
          .where('delivery_phone', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'enRoute')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['receiverName'] ?? '',
          customerAddress: data['address'] ?? '',
          deliveryPhoneNumber: data['delivery_phone'],
          deliveryName: data['delivery_name'],
          type: DeliveryType.parcel,
          status: _mapOrderStatus(data['status']),
          amount: (data['prix'] ?? 0.0).toDouble(),
          deliveryFee: 800.0, // Frais de livraison fixe pour les colis
          description: data['instructions'] ?? 'Colis',
          createdAt: data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          assignedAt: data['assigned_at'] is String
              ? DateTime.parse(data['assigned_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des colis du livreur: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'une commande restaurant
  static Future<void> updateRestaurantOrderStatus(
    String orderId,
    DeliveryStatus status,
  ) async {
    try {
      final updateData = {'status': _mapDeliveryStatusToOrderStatus(status)};

      if (status == DeliveryStatus.livre) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);
    } catch (e) {
      print(
          'Erreur lors de la mise à jour du statut de la commande restaurant: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut d'un colis
  static Future<void> updateParcelStatus(
    String parcelId,
    DeliveryStatus status,
  ) async {
    try {
      final updateData = {'status': _mapDeliveryStatusToParcelStatus(status)};

      if (status == DeliveryStatus.livre) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _firestore.collection('parcels').doc(parcelId).update(updateData);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut du colis: $e');
      rethrow;
    }
  }

  // Marquer une commande restaurant comme livrée
  static Future<void> markRestaurantOrderAsDelivered(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'livre',
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la marque comme livrée: $e');
      rethrow;
    }
  }

  // Marquer une commande restaurant comme non livrée
  static Future<void> markRestaurantOrderAsNotDelivered(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'nonLivre',
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la marque comme non livrée: $e');
      rethrow;
    }
  }

  // Marquer un colis comme livré
  static Future<void> markParcelAsDelivered(String parcelId) async {
    try {
      await _firestore.collection('parcels').doc(parcelId).update({
        'status': 'livre',
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la marque comme livré: $e');
      rethrow;
    }
  }

  // Marquer un colis comme non livré
  static Future<void> markParcelAsNotDelivered(String parcelId) async {
    try {
      await _firestore.collection('parcels').doc(parcelId).update({
        'status': 'nonLivre',
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la marque comme non livré: $e');
      rethrow;
    }
  }

  // ===== STATISTIQUES =====

  // Calculer les gains du jour pour un livreur
  static Future<double> getTodayEarnings(String phoneNumber) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Gains des commandes restaurant
      final restaurantQuery = await _firestore
          .collection('orders')
          .where('delivery_phone', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'livre')
          .where('completed_at',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('completed_at', isLessThan: endOfDay.toIso8601String())
          .get();

      // Gains des colis
      final parcelQuery = await _firestore
          .collection('parcels')
          .where('delivery_phone', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'livre')
          .where('completed_at',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('completed_at', isLessThan: endOfDay.toIso8601String())
          .get();

      double totalEarnings = 0;

      for (final doc in restaurantQuery.docs) {
        final data = doc.data();
        totalEarnings += (data['deliveryFee'] ?? 0.0).toDouble();
      }

      for (final doc in parcelQuery.docs) {
        final data = doc.data();
        totalEarnings += 800.0; // Frais de livraison fixe pour les colis
      }

      return totalEarnings;
    } catch (e) {
      print('Erreur lors du calcul des gains du jour: $e');
      return 0.0;
    }
  }

  // ===== UTILITAIRES =====

  static DeliveryStatus _mapOrderStatus(String? status) {
    switch (status) {
      case 'reception':
        return DeliveryStatus.reception;
      case 'enRoute':
        return DeliveryStatus.enRoute;
      case 'livre':
        return DeliveryStatus.livre;
      case 'nonLivre':
        return DeliveryStatus.nonLivre;
      default:
        return DeliveryStatus.reception;
    }
  }

  static String _mapDeliveryStatusToOrderStatus(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.reception:
        return 'reception';
      case DeliveryStatus.enRoute:
        return 'enRoute';
      case DeliveryStatus.livre:
        return 'livre';
      case DeliveryStatus.nonLivre:
        return 'nonLivre';
    }
  }

  static String _mapDeliveryStatusToParcelStatus(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.reception:
        return 'reception';
      case DeliveryStatus.enRoute:
        return 'enRoute';
      case DeliveryStatus.livre:
        return 'livre';
      case DeliveryStatus.nonLivre:
        return 'nonLivre';
    }
  }

  // Récupérer les commandes restaurant assignées (pour gestion)
  static Future<List<DeliveryOrder>> getAssignedRestaurantOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'enRoute')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['customer_name'] ?? 'Client',
          customerAddress: data['address'] ?? '',
          deliveryPhoneNumber: data['delivery_phone'],
          deliveryName: data['delivery_name'],
          type: DeliveryType.restaurant,
          status: _mapOrderStatus(data['status']),
          amount: (data['subtotal'] ?? 0.0).toDouble(),
          deliveryFee: (data['deliveryFee'] ?? 500.0).toDouble(),
          description:
              data['items']?.map((item) => item['name'] ?? '').join(', ') ??
                  'Commande restaurant',
          createdAt: data['createdAt'] is String
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
          assignedAt: data['assigned_at'] is String
              ? DateTime.parse(data['assigned_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes assignées: $e');
      return [];
    }
  }

  // Récupérer les colis assignés (pour gestion)
  static Future<List<DeliveryOrder>> getAssignedParcelOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('parcels')
          .where('status', isEqualTo: 'enRoute')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['receiverName'] ?? '',
          customerAddress: data['address'] ?? '',
          deliveryPhoneNumber: data['delivery_phone'],
          deliveryName: data['delivery_name'],
          type: DeliveryType.parcel,
          status: _mapOrderStatus(data['status']),
          amount: (data['prix'] ?? 0.0).toDouble(),
          deliveryFee: 800.0,
          description: data['instructions'] ?? 'Colis',
          createdAt: data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          assignedAt: data['assigned_at'] is String
              ? DateTime.parse(data['assigned_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des colis assignés: $e');
      return [];
    }
  }
}
