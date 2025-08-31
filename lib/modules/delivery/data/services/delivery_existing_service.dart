import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/delivery_user.dart';
import '../../domain/entities/delivery_order.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/notification_service.dart';

class DeliveryExistingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final NotificationService _notificationService = NotificationService();

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

  // Mettre à jour la position après une livraison
  static Future<void> updatePositionAfterDelivery(String phoneNumber) async {
    try {
      print('📍 Mise à jour position après livraison pour: $phoneNumber');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _firestore.collection('users').doc(phoneNumber).update({
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
        'last_delivery_completion': FieldValue.serverTimestamp(),
      });

      print(
          '✅ Position mise à jour après livraison: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Erreur mise à jour position après livraison: $e');
    }
  }

  // Mettre à jour la disponibilité d'un livreur
  static Future<void> updateDeliveryUserAvailability(
    String phoneNumber,
    bool isAvailable,
  ) async {
    try {
      print(
          '🔄 Mise à jour disponibilité pour: $phoneNumber, disponible: $isAvailable');

      if (isAvailable) {
        // Si le livreur devient disponible, récupérer sa position actuelle
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await _firestore.collection('users').doc(phoneNumber).update({
          'active': isAvailable,
          'current_latitude': position.latitude,
          'current_longitude': position.longitude,
          'last_location_update': FieldValue.serverTimestamp(),
        });

        print(
            '✅ Disponibilité activée avec position: ${position.latitude}, ${position.longitude}');
      } else {
        // Si le livreur devient indisponible, juste désactiver
        await _firestore.collection('users').doc(phoneNumber).update({
          'active': isAvailable,
        });

        print('❌ Disponibilité désactivée');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de la disponibilité: $e');
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

        // Récupérer les informations correctes du colis
        final expediteurNom = data['expediteurNom'] ?? data['senderName'] ?? '';
        final destinataireNom =
            data['destinataireNom'] ?? data['receiverName'] ?? '';
        final expediteurLieu = data['expediteurLieu'] ?? '';
        final destinataireLieu = data['destinataireLieu'] ?? '';
        final phoneNumber = data['phoneNumber'] ?? '';

        // Construire l'adresse complète
        String customerAddress = '';
        if (expediteurLieu.isNotEmpty && destinataireLieu.isNotEmpty) {
          customerAddress = 'De: $expediteurLieu → À: $destinataireLieu';
        } else if (expediteurLieu.isNotEmpty) {
          customerAddress = 'Lieu: $expediteurLieu';
        } else if (destinataireLieu.isNotEmpty) {
          customerAddress = 'Lieu: $destinataireLieu';
        } else {
          customerAddress = 'Adresse non spécifiée';
        }

        // Nom du client (utiliser le destinataire ou l'expéditeur)
        String customerName =
            destinataireNom.isNotEmpty ? destinataireNom : expediteurNom;
        if (customerName.isEmpty) {
          customerName = 'Client inconnu';
        }

        print('📦 Colis ${doc.id}: $customerName - $customerAddress');

        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: phoneNumber,
          customerName: customerName,
          customerAddress: customerAddress,
          type: DeliveryType.parcel,
          status: DeliveryStatus.reception,
          amount: (data['prix'] ?? 0.0).toDouble(),
          deliveryFee: 800.0, // Frais de livraison fixe pour les colis
          description: data['instructions'] ?? data['typeProduit'] ?? 'Colis',
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
      print(
          '📦 Assignation colis $parcelId à $deliveryName ($deliveryPhoneNumber)');

      // Récupérer les informations du colis pour la notification
      final parcelDoc =
          await _firestore.collection('parcels').doc(parcelId).get();
      if (!parcelDoc.exists) {
        throw Exception('Colis non trouvé');
      }

      final parcelData = parcelDoc.data()!;
      final expediteurLieu = parcelData['expediteurLieu'] ?? '';
      final destinataireLieu = parcelData['destinataireLieu'] ?? '';
      final prix = (parcelData['prix'] ?? 0.0).toDouble();

      // Construire l'adresse pour la notification
      String senderAddress = '';
      if (expediteurLieu.isNotEmpty && destinataireLieu.isNotEmpty) {
        senderAddress = 'De: $expediteurLieu → À: $destinataireLieu';
      } else if (expediteurLieu.isNotEmpty) {
        senderAddress = 'Lieu: $expediteurLieu';
      } else if (destinataireLieu.isNotEmpty) {
        senderAddress = 'Lieu: $destinataireLieu';
      } else {
        senderAddress = 'Adresse non spécifiée';
      }

      await _firestore.collection('parcels').doc(parcelId).update({
        'delivery_phone_number': deliveryPhoneNumber,
        'delivery_name': deliveryName,
        'status': 'enRoute',
        'assigned_at': FieldValue.serverTimestamp(),
      });

      print('✅ Colis $parcelId assigné avec succès');

      // Envoyer la notification au livreur
      await _notificationService.notifyParcelAssignedToDelivery(
        parcelId: parcelId,
        deliveryUserPhone: deliveryPhoneNumber,
        senderAddress: senderAddress,
        total: prix,
      );

      print('📱 Notification envoyée au livreur $deliveryName');
    } catch (e) {
      print('❌ Erreur lors de l\'assignation du colis: $e');
      rethrow;
    }
  }

  // ===== COMMANDES ASSIGNÉES À UN LIVREUR =====

  // Récupérer les commandes restaurant assignées à un livreur
  static Future<List<DeliveryOrder>> getRestaurantOrdersForDeliveryUser(
      String phoneNumber) async {
    try {
      print('🔍 Recherche commandes restaurant pour: $phoneNumber');

      // Le phoneNumber du livreur local correspond au champ 'assignedTo' dans Firestore
      var querySnapshot = await _firestore
          .collection('orders')
          .where('assignedTo', isEqualTo: phoneNumber)
          .get();

      print(
          '📦 Commandes trouvées avec assignedTo: ${querySnapshot.docs.length}');

      // Si aucune commande trouvée, essayer avec les anciens champs pour compatibilité
      if (querySnapshot.docs.isEmpty) {
        print(
            '🔄 Aucune commande trouvée, essai avec delivery_phone_number...');
        querySnapshot = await _firestore
            .collection('orders')
            .where('delivery_phone_number', isEqualTo: phoneNumber)
            .get();
        print(
            '📦 Commandes trouvées avec delivery_phone_number: ${querySnapshot.docs.length}');
      }

      if (querySnapshot.docs.isEmpty) {
        print('🔄 Aucune commande trouvée, essai avec delivery_phone...');
        querySnapshot = await _firestore
            .collection('orders')
            .where('delivery_phone', isEqualTo: phoneNumber)
            .get();
        print(
            '📦 Commandes trouvées avec delivery_phone: ${querySnapshot.docs.length}');
      }

      // Afficher toutes les commandes pour diagnostiquer
      final allOrders = await _firestore.collection('orders').get();
      print('📋 Total commandes dans la base: ${allOrders.docs.length}');

      for (final doc in allOrders.docs) {
        final data = doc.data();
        print(
            '📄 Commande ${doc.id}: delivery_phone_number=${data['delivery_phone_number']}, delivery_phone=${data['delivery_phone']}, status=${data['status']}');
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['customer_name'] ?? 'Client',
          customerAddress: data['address'] ?? '',
          deliveryPhoneNumber: data['assignedTo'] ??
              data['delivery_phone_number'] ??
              data['delivery_phone'] ??
              '',
          deliveryName: data['assignedToName'] ?? data['delivery_name'] ?? '',
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
          '❌ Erreur lors de la récupération des commandes restaurant du livreur: $e');
      return [];
    }
  }

  // Récupérer les colis assignés à un livreur
  static Future<List<DeliveryOrder>> getParcelOrdersForDeliveryUser(
      String phoneNumber) async {
    try {
      print('🔍 Recherche colis pour: $phoneNumber');

      // Le phoneNumber du livreur local correspond au champ 'assignedTo' dans Firestore
      var querySnapshot = await _firestore
          .collection('parcels')
          .where('assignedTo', isEqualTo: phoneNumber)
          .get();

      print('📦 Colis trouvés avec assignedTo: ${querySnapshot.docs.length}');

      // Si aucun colis trouvé, essayer avec les anciens champs pour compatibilité
      if (querySnapshot.docs.isEmpty) {
        print('🔄 Aucun colis trouvé, essai avec delivery_phone_number...');
        querySnapshot = await _firestore
            .collection('parcels')
            .where('delivery_phone_number', isEqualTo: phoneNumber)
            .get();
        print(
            '📦 Colis trouvés avec delivery_phone_number: ${querySnapshot.docs.length}');
      }

      if (querySnapshot.docs.isEmpty) {
        print('🔄 Aucun colis trouvé, essai avec delivery_phone...');
        querySnapshot = await _firestore
            .collection('parcels')
            .where('delivery_phone', isEqualTo: phoneNumber)
            .get();
        print(
            '📦 Colis trouvés avec delivery_phone: ${querySnapshot.docs.length}');
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return DeliveryOrder(
          id: doc.id,
          customerPhoneNumber: data['phone'] ?? '',
          customerName: data['receiverName'] ?? '',
          customerAddress: data['address'] ?? '',
          deliveryPhoneNumber: data['assignedTo'] ??
              data['delivery_phone_number'] ??
              data['delivery_phone'] ??
              '',
          deliveryName: data['assignedToName'] ?? data['delivery_name'] ?? '',
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
      print('❌ Erreur lors de la récupération des colis du livreur: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'une commande restaurant
  static Future<void> updateRestaurantOrderStatus(
      String orderId, DeliveryStatus status) async {
    try {
      print('🔄 Mise à jour statut commande restaurant $orderId: $status');

      // Récupérer les informations de la commande pour la notification
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Commande non trouvée');
      }

      final orderData = orderDoc.data()!;
      final customerPhone = orderData['phone'] ?? '';
      final deliveryName = orderData['delivery_name'] ?? 'Livreur';

      await _firestore.collection('orders').doc(orderId).update({
        'status': _mapDeliveryStatusToString(status),
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Statut commande restaurant mis à jour');

      // Envoyer la notification au client
      if (customerPhone.isNotEmpty) {
        await _notificationService.notifyDeliveryStatusToCustomer(
          orderId: orderId,
          customerPhone: customerPhone,
          status: _mapDeliveryStatusToString(status),
          deliveryUser: deliveryName,
        );
        print('📱 Notification statut envoyée au client');
      }
    } catch (e) {
      print('❌ Erreur mise à jour statut commande restaurant: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut d'un colis
  static Future<void> updateParcelStatus(
      String parcelId, DeliveryStatus status) async {
    try {
      print('🔄 Mise à jour statut colis $parcelId: $status');

      // Récupérer les informations du colis pour la notification
      final parcelDoc =
          await _firestore.collection('parcels').doc(parcelId).get();
      if (!parcelDoc.exists) {
        throw Exception('Colis non trouvé');
      }

      final parcelData = parcelDoc.data()!;
      final customerPhone = parcelData['phoneNumber'] ?? '';
      final deliveryName = parcelData['delivery_name'] ?? 'Livreur';

      await _firestore.collection('parcels').doc(parcelId).update({
        'status': _mapDeliveryStatusToString(status),
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Statut colis mis à jour');

      // Envoyer la notification au client
      if (customerPhone.isNotEmpty) {
        await _notificationService.notifyDeliveryStatusToCustomer(
          orderId: parcelId,
          customerPhone: customerPhone,
          status: _mapDeliveryStatusToString(status),
          deliveryUser: deliveryName,
        );
        print('📱 Notification statut colis envoyée au client');
      }
    } catch (e) {
      print('❌ Erreur mise à jour statut colis: $e');
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
      case 'assigned': // Nouveau statut pour les commandes assignées
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

  static String _mapDeliveryStatusToString(DeliveryStatus status) {
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
