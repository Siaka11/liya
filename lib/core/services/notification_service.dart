import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liya/core/services/fcm_service.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FCMService _fcmService = FCMService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  /// Notification: Nouvelle commande de plat → Admin
  Future<void> notifyNewOrderToAdmin({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required String restaurantName,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      print('📤 Notification nouvelle commande → Admin');

      final title = '🆕 Nouvelle commande reçue';
      final body =
          '$customerName a commandé ${items.length} article(s) pour ${total.toStringAsFixed(0)} FCFA';

      final data = {
        'type': 'new_order',
        'orderId': orderId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'restaurantName': restaurantName,
        'total': total.toString(),
        'items': items.toString(),
      };

      await _fcmService.sendNotificationToRole(
        role: 'admin',
        title: title,
        body: body,
        data: data,
      );

      // Sauvegarder la notification dans Firestore pour l'historique
      await _saveNotificationToFirestore(
        type: 'new_order',
        title: title,
        body: body,
        data: data,
        targetRole: 'admin',
      );

      print('✅ Notification nouvelle commande envoyée aux admins');
    } catch (e) {
      print('❌ Erreur notification nouvelle commande: $e');
    }
  }

  /// Notification: Nouveau colis → Admin
  Future<void> notifyNewParcelToAdmin({
    required String parcelId,
    required String customerName,
    required String customerPhone,
    required String destination,
    required double total,
  }) async {
    try {
      print('📤 Notification nouveau colis → Admin');

      final title = '📦 Nouveau colis à expédier';
      final body =
          '$customerName veut expédier un colis vers $destination pour ${total.toStringAsFixed(0)} FCFA';

      final data = {
        'type': 'new_parcel',
        'parcelId': parcelId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'destination': destination,
        'total': total.toString(),
      };

      await _fcmService.sendNotificationToRole(
        role: 'admin',
        title: title,
        body: body,
        data: data,
      );

      await _saveNotificationToFirestore(
        type: 'new_parcel',
        title: title,
        body: body,
        data: data,
        targetRole: 'admin',
      );

      print('✅ Notification nouveau colis envoyée aux admins');
    } catch (e) {
      print('❌ Erreur notification nouveau colis: $e');
    }
  }

  /// Notification: Commande assignée → Livreur
  Future<void> notifyOrderAssignedToDelivery({
    required String orderId,
    required String deliveryPhone,
    required String customerName,
    required String customerPhone,
    required String address,
    required double total,
    required double deliveryFee,
  }) async {
    try {
      print('📤 Notification commande assignée → Livreur: $deliveryPhone');

      final title = '🚚 Nouvelle livraison assignée';
      final body =
          'Livraison pour $customerName - ${total.toStringAsFixed(0)} FCFA + ${deliveryFee.toStringAsFixed(0)} FCFA de frais';

      final data = {
        'type': 'order_assigned',
        'orderId': orderId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'address': address,
        'total': total.toString(),
        'deliveryFee': deliveryFee.toString(),
      };

      await _fcmService.sendNotificationToUser(
        userPhoneNumber: deliveryPhone,
        title: title,
        body: body,
        data: data,
      );

      await _saveNotificationToFirestore(
        type: 'order_assigned',
        title: title,
        body: body,
        data: data,
        targetUser: deliveryPhone,
      );

      print('✅ Notification commande assignée envoyée au livreur');
    } catch (e) {
      print('❌ Erreur notification commande assignée: $e');
    }
  }

  /// Notification: Colis assigné → Livreur
  Future<void> notifyParcelAssignedToDelivery({
    required String parcelId,
    required String deliveryPhone,
    required String customerName,
    required String customerPhone,
    required String destination,
    required double total,
  }) async {
    try {
      print('📤 Notification colis assigné → Livreur: $deliveryPhone');

      final title = '📦 Nouveau colis à livrer';
      final body =
          'Colis de $customerName vers $destination - ${total.toStringAsFixed(0)} FCFA';

      final data = {
        'type': 'parcel_assigned',
        'parcelId': parcelId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'destination': destination,
        'total': total.toString(),
      };

      await _fcmService.sendNotificationToUser(
        userPhoneNumber: deliveryPhone,
        title: title,
        body: body,
        data: data,
      );

      await _saveNotificationToFirestore(
        type: 'parcel_assigned',
        title: title,
        body: body,
        data: data,
        targetUser: deliveryPhone,
      );

      print('✅ Notification colis assigné envoyée au livreur');
    } catch (e) {
      print('❌ Erreur notification colis assigné: $e');
    }
  }

  /// Notification: Livraison en cours → Client
  Future<void> notifyDeliveryStartedToCustomer({
    required String orderId,
    required String customerPhone,
    required String deliveryName,
    required String deliveryPhone,
    required String estimatedTime,
  }) async {
    try {
      print('📤 Notification livraison en cours → Client: $customerPhone');

      final title = '🚚 Votre commande est en route';
      final body =
          '$deliveryName a commencé la livraison. Arrivée estimée: $estimatedTime';

      final data = {
        'type': 'delivery_started',
        'orderId': orderId,
        'deliveryName': deliveryName,
        'deliveryPhone': deliveryPhone,
        'estimatedTime': estimatedTime,
      };

      await _fcmService.sendNotificationToUser(
        userPhoneNumber: customerPhone,
        title: title,
        body: body,
        data: data,
      );

      await _saveNotificationToFirestore(
        type: 'delivery_started',
        title: title,
        body: body,
        data: data,
        targetUser: customerPhone,
      );

      print('✅ Notification livraison en cours envoyée au client');
    } catch (e) {
      print('❌ Erreur notification livraison en cours: $e');
    }
  }

  /// Notification: Livraison terminée → Client
  Future<void> notifyDeliveryCompletedToCustomer({
    required String orderId,
    required String customerPhone,
    required String deliveryName,
  }) async {
    try {
      print('📤 Notification livraison terminée → Client: $customerPhone');

      final title = '✅ Livraison terminée';
      final body =
          '$deliveryName a livré votre commande. Merci de votre confiance !';

      final data = {
        'type': 'delivery_completed',
        'orderId': orderId,
        'deliveryName': deliveryName,
      };

      await _fcmService.sendNotificationToUser(
        userPhoneNumber: customerPhone,
        title: title,
        body: body,
        data: data,
      );

      await _saveNotificationToFirestore(
        type: 'delivery_completed',
        title: title,
        body: body,
        data: data,
        targetUser: customerPhone,
      );

      print('✅ Notification livraison terminée envoyée au client');
    } catch (e) {
      print('❌ Erreur notification livraison terminée: $e');
    }
  }

  /// Sauvegarder une notification dans Firestore pour l'historique
  Future<void> _saveNotificationToFirestore({
    required String type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? targetRole,
    String? targetUser,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': type,
        'title': title,
        'body': body,
        'data': data,
        'targetRole': targetRole,
        'targetUser': targetUser,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      print('💾 Notification sauvegardée dans Firestore');
    } catch (e) {
      print('❌ Erreur sauvegarde notification: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });

      print('✅ Notification marquée comme lue: $notificationId');
    } catch (e) {
      print('❌ Erreur marquage notification: $e');
    }
  }

  /// Obtenir les notifications d'un utilisateur
  Stream<QuerySnapshot> getUserNotifications(String userPhone) {
    return _firestore
        .collection('notifications')
        .where('targetUser', isEqualTo: userPhone)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Obtenir les notifications d'un rôle
  Stream<QuerySnapshot> getRoleNotifications(String role) {
    return _firestore
        .collection('notifications')
        .where('targetRole', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}
