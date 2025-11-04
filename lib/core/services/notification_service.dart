import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fcm_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FCMService _fcmService = FCMService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // URLs des Firebase Functions
  static const String _baseUrl =
      'https://us-central1-liya-a4a9f.cloudfunctions.net';
  static const String _sendNotificationUrl = '$_baseUrl/sendNotification';
  static const String _sendNotificationToRoleUrl =
      '$_baseUrl/sendNotificationToRole';

  /// Notifier les admins d'une nouvelle commande
  Future<bool> notifyNewOrderToAdmin({
    required String orderId,
    required String customerName,
    required double total,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendNotificationToRoleUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': 'admin',
          'title': '🆕 Nouvelle commande reçue',
          'body':
              'Commande #$orderId de $customerName - ${total.toStringAsFixed(0)} FCFA',
          'data': {
            'type': 'new_order',
            'order_id': orderId,
            'customer_name': customerName,
            'total': total.toString(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            '✅ Notification nouvelle commande envoyée aux admins: ${result['message']}');
        await _saveNotificationToFirestore(
          recipientType: 'admin',
          recipientRole: 'admin',
          notificationType: 'new_order',
          title: '🆕 Nouvelle commande reçue',
          body:
              'Commande #$orderId de $customerName - ${total.toStringAsFixed(0)} FCFA',
          data: {
            'type': 'new_order',
            'order_id': orderId,
            'customer_name': customerName,
            'total': total.toString(),
          },
        );
        return true;
      } else {
        print(
            '❌ Erreur notification nouvelle commande: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur notification nouvelle commande: $e');
      return false;
    }
  }

  /// Notifier un livreur d'une commande assignée
  Future<bool> notifyOrderAssignedToDelivery({
    required String orderId,
    required String deliveryUserPhone,
    required String customerAddress,
    required double total,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendNotificationUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': deliveryUserPhone,
          'title': '📦 Nouvelle livraison assignée',
          'body': 'Commande #$orderId - $customerAddress',
          'data': {
            'type': 'order_assigned',
            'order_id': orderId,
            'customer_address': customerAddress,
            'total': total.toString(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            '✅ Notification commande assignée envoyée au livreur: ${result['message']}');
        await _saveNotificationToFirestore(
          recipientType: 'individual',
          recipientPhone: deliveryUserPhone,
          notificationType: 'order_assigned',
          title: '📦 Nouvelle livraison assignée',
          body: 'Commande #$orderId - $customerAddress',
          data: {
            'type': 'order_assigned',
            'order_id': orderId,
            'customer_address': customerAddress,
            'total': total.toString(),
          },
        );
        return true;
      } else {
        print(
            '❌ Erreur notification commande assignée: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur notification commande assignée: $e');
      return false;
    }
  }

  /// Notifier un client du statut de sa livraison
  Future<bool> notifyDeliveryStatusToCustomer({
    required String orderId,
    required String customerPhone,
    required String status,
    required String deliveryUser,
  }) async {
    try {
      String title, body;
      switch (status) {
        case 'started':
          title = '🚚 Livraison commencée';
          body =
              'Votre commande #$orderId est en cours de livraison par $deliveryUser';
          break;
        case 'completed':
          title = '✅ Livraison terminée';
          body = 'Votre commande #$orderId a été livrée avec succès';
          break;
        default:
          title = '📦 Mise à jour livraison';
          body = 'Statut de votre commande #$orderId: $status';
      }

      final response = await http.post(
        Uri.parse(_sendNotificationUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': customerPhone,
          'title': title,
          'body': body,
          'data': {
            'type': 'delivery_status',
            'order_id': orderId,
            'status': status,
            'delivery_user': deliveryUser,
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            '✅ Notification statut livraison envoyée au client: ${result['message']}');
        await _saveNotificationToFirestore(
          recipientType: 'individual',
          recipientPhone: customerPhone,
          notificationType: 'delivery_status',
          title: title,
          body: body,
          data: {
            'type': 'delivery_status',
            'order_id': orderId,
            'status': status,
            'delivery_user': deliveryUser,
          },
        );
        return true;
      } else {
        print('❌ Erreur notification statut livraison: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur notification statut livraison: $e');
      return false;
    }
  }

  /// Notifier les admins d'un nouveau colis
  Future<bool> notifyNewParcelToAdmin({
    required String parcelId,
    required String senderName,
    required double total,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendNotificationToRoleUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': 'admin',
          'title': '📦 Nouveau colis reçu',
          'body':
              /*'Colis #$parcelId de $senderName - ${total.toStringAsFixed(0)} FCFA',*/
              'Colis #$parcelId de $senderName ',
          'data': {
            'type': 'new_parcel',
            'parcel_id': parcelId,
            'sender_name': senderName,
            'total': total.toString(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            '✅ Notification nouveau colis envoyée aux admins: ${result['message']}');
        await _saveNotificationToFirestore(
          recipientType: 'admin',
          recipientRole: 'admin',
          notificationType: 'new_parcel',
          title: '📦 Nouveau colis reçu',
          body:
              'Colis #$parcelId de $senderName - ${total.toStringAsFixed(0)} FCFA',
          data: {
            'type': 'new_parcel',
            'parcel_id': parcelId,
            'sender_name': senderName,
            'total': total.toString(),
          },
        );
        return true;
      } else {
        print('❌ Erreur notification nouveau colis: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur notification nouveau colis: $e');
      return false;
    }
  }

  /// Notifier un livreur d'un colis assigné
  Future<bool> notifyParcelAssignedToDelivery({
    required String parcelId,
    required String deliveryUserPhone,
    required String senderAddress,
    required double total,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendNotificationUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': deliveryUserPhone,
          'title': '📦 Nouveau colis à livrer',
          'body': 'Colis #$parcelId - $senderAddress',
          'data': {
            'type': 'parcel_assigned',
            'parcel_id': parcelId,
            'sender_address': senderAddress,
            'total': total.toString(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print(
            '✅ Notification colis assigné envoyée au livreur: ${result['message']}');
        await _saveNotificationToFirestore(
          recipientType: 'individual',
          recipientPhone: deliveryUserPhone,
          notificationType: 'parcel_assigned',
          title: '📦 Nouveau colis à livrer',
          body: 'Colis #$parcelId - $senderAddress',
          data: {
            'type': 'parcel_assigned',
            'parcel_id': parcelId,
            'sender_address': senderAddress,
            'total': total.toString(),
          },
        );
        return true;
      } else {
        print('❌ Erreur notification colis assigné: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur notification colis assigné: $e');
      return false;
    }
  }

  /// Sauvegarder l'historique des notifications dans Firestore
  Future<void> _saveNotificationToFirestore({
    required String recipientType,
    String? recipientRole,
    String? recipientPhone,
    required String notificationType,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final notificationData = <String, dynamic>{
        'type': notificationType,
        'title': title,
        'body': body,
        'data': data,
        'sent_at': FieldValue.serverTimestamp(),
        'read': false,
        'success': true,
      };

      // Ajouter les champs spécifiques selon le type de destinataire
      if (recipientType == 'admin') {
        notificationData['recipient_role'] = recipientRole ?? 'admin';
      } else {
        notificationData['recipient_phone'] = recipientPhone ?? '';
      }

      await _firestore.collection('notifications').add(notificationData);
      print('✅ Notification sauvegardée dans Firestore: $notificationType');
    } catch (e) {
      print('❌ Erreur sauvegarde notification dans Firestore: $e');
    }
  }
}
