import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_factory.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalStorageFactory _localStorage = LocalStorageFactory();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NavigationService _navigationService = NavigationService();

  // URLs des Firebase Functions
  static const String _baseUrl =
      'https://us-central1-liya-a4a9f.cloudfunctions.net';
  static const String _sendNotificationUrl = '$_baseUrl/sendNotification';
  static const String _sendNotificationToRoleUrl =
      '$_baseUrl/sendNotificationToRole';

  /// Initialiser FCM après authentification
  Future<void> initializeAfterAuth() async {
    print('🚀 Début initialisation FCM...');
    try {
      // Initialiser les notifications locales
      print('📱 Initialisation notifications locales...');
      await _initializeLocalNotifications();

      // Demander les permissions
      print('🔐 Demande des permissions FCM...');
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📊 Statut des permissions: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permissions FCM accordées');

        // Obtenir le token FCM
        print('🔑 Tentative de récupération du token FCM...');
        String? token = await _messaging.getToken();
        print('🔑 Token FCM brut: $token');

        if (token != null) {
          print('📱 Token FCM obtenu: ${token.substring(0, 20)}...');
          print('📱 Token FCM complet: $token');
          await _saveFCMTokenToFirestore(token);
        } else {
          print('❌ Token FCM est null !');
        }

        // Écouter les changements de token
        _messaging.onTokenRefresh.listen((newToken) {
          print('🔄 Token FCM renouvelé: ${newToken.substring(0, 20)}...');
          _saveFCMTokenToFirestore(newToken);
        });

        // Configurer les handlers de messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

        // Gérer les messages au démarrage
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleBackgroundMessage(initialMessage);
        }
      } else {
        print('❌ Permissions FCM refusées: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ Erreur initialisation FCM: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📱 Notification locale cliquée: ${response.payload}');
        // Gérer le clic sur la notification locale
        _handleNotificationClick(response.payload);
      },
    );

    // Créer les canaux de notification pour Android
    await _createNotificationChannels();
  }

  /// Créer les canaux de notification pour Android
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel defaultChannel =
        AndroidNotificationChannel(
      'default',
      'Notifications par défaut',
      description: 'Canal pour les notifications générales',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel ordersChannel = AndroidNotificationChannel(
      'orders',
      'Commandes',
      description: 'Canal pour les notifications de commandes',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel deliveryChannel =
        AndroidNotificationChannel(
      'delivery',
      'Livraisons',
      description: 'Canal pour les notifications de livraison',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel deliveryStatusChannel =
        AndroidNotificationChannel(
      'delivery_status',
      'Statut de livraison',
      description: 'Canal pour les mises à jour de statut de livraison',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(ordersChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deliveryChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(deliveryStatusChannel);
  }

  /// Test direct de sauvegarde du token FCM
  Future<void> testDirectTokenSave() async {
    try {
      print('🧪 Test direct de sauvegarde du token FCM...');

      // Récupérer le token FCM
      String? token = await _messaging.getToken();
      if (token == null) {
        print('❌ Impossible d\'obtenir le token FCM');
        return;
      }

      print('📱 Token FCM obtenu: ${token.substring(0, 20)}...');

      // Récupérer les détails utilisateur
      final userDetails = await _localStorage.getUserDetails();
      print('👤 UserDetails: $userDetails');

      if (userDetails == null || userDetails.isEmpty) {
        print('❌ Aucun userDetails trouvé');
        return;
      }

      final phone = userDetails['phoneNumber'];
      if (phone == null) {
        print('❌ Aucun numéro de téléphone trouvé dans userDetails');
        return;
      }

      print('📞 Numéro de téléphone: $phone');

      // Sauvegarder directement dans Firestore
      await _saveFCMTokenDirectlyToFirestore(phone, token);

      print('✅ Test de sauvegarde directe terminé');
    } catch (e) {
      print('❌ Erreur test direct: $e');
    }
  }

  /// Vérifier si le token FCM est sauvegardé dans Firestore
  Future<bool> checkFCMTokenInFirestore() async {
    try {
      final userDetails = await _localStorage.getUserDetails();
      if (userDetails != null && userDetails['phoneNumber'] != null) {
        String phone = userDetails['phoneNumber'];
        String normalizedPhone =
            phone.startsWith('+225') ? phone : '+225$phone';

        final firestore = FirebaseFirestore.instance;
        final userDoc =
            await firestore.collection('users').doc(normalizedPhone).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final hasToken = userData?['fcm_token'] != null;
          print(
              '🔍 Token FCM dans Firestore pour $normalizedPhone: ${hasToken ? "✅ Présent" : "❌ Absent"}');
          return hasToken;
        }
      }
      return false;
    } catch (e) {
      print('❌ Erreur vérification token FCM dans Firestore: $e');
      return false;
    }
  }

  /// Forcer la sauvegarde du token FCM avec le numéro de téléphone directement
  Future<void> forceSaveFCMTokenWithPhone(String phoneNumber) async {
    print('🔄 Force sauvegarde du token FCM avec phone: $phoneNumber');
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print('📱 Token FCM obtenu: ${token.substring(0, 20)}...');

        // Normaliser le numéro pour Firestore
        String normalizedPhone =
            phoneNumber.startsWith('+225') ? phoneNumber : '+225$phoneNumber';
        print('📱 Phone normalisé: $normalizedPhone');

        // Sauvegarder directement dans Firestore
        await _saveFCMTokenDirectlyToFirestore(normalizedPhone, token);
        print('✅ Token FCM sauvegardé avec succès');
      } else {
        print('❌ Impossible d\'obtenir le token FCM');
      }
    } catch (e) {
      print('❌ Erreur force sauvegarde token FCM: $e');
    }
  }

  /// Forcer la sauvegarde du token FCM (méthode publique)
  Future<void> forceSaveFCMToken() async {
    print('🔄 Force sauvegarde du token FCM...');
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print('📱 Token FCM obtenu: ${token.substring(0, 20)}...');
        await _saveFCMTokenToFirestore(token);
      } else {
        print('❌ Impossible d\'obtenir le token FCM');
      }
    } catch (e) {
      print('❌ Erreur force sauvegarde token FCM: $e');
    }
  }

  /// Sauvegarder le token FCM dans Firestore
  Future<void> _saveFCMTokenToFirestore(String token) async {
    print('🔄 Début sauvegarde token FCM...');
    try {
      // Récupérer le numéro de téléphone depuis LocalStorage
      print('📱 Récupération userDetails depuis LocalStorage...');
      final userDetails = await _localStorage.getUserDetails();
      print('📱 userDetails récupéré: $userDetails');

      if (userDetails != null && userDetails['phoneNumber'] != null) {
        String phone = userDetails['phoneNumber'];
        print('📱 Phone trouvé: $phone');

        // Normaliser le numéro pour Firestore
        String normalizedPhone =
            phone.startsWith('+225') ? phone : '+225$phone';
        print('📱 Phone normalisé: $normalizedPhone');

        print('📱 Sauvegarde token FCM pour: $normalizedPhone');
        print('📱 Token: ${token.substring(0, 20)}...');

        // Mettre à jour le token dans Firestore
        await _updateFCMTokenInFirestore(normalizedPhone, token);
        print('✅ Token FCM sauvegardé dans Firestore');
      } else {
        print(
            '⚠️ Impossible de récupérer le numéro de téléphone pour sauvegarder le token FCM');
        print('⚠️ userDetails: $userDetails');
        print('⚠️ userDetails est null: ${userDetails == null}');
        if (userDetails != null) {
          print('⚠️ Clés disponibles: ${userDetails.keys.toList()}');
        }
      }
    } catch (e) {
      print('❌ Erreur sauvegarde token FCM: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Mettre à jour le token FCM dans Firestore via Firebase Function
  Future<void> _updateFCMTokenInFirestore(String phone, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/updateFCMToken'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Token FCM mis à jour dans Firestore via Firebase Function');
      } else {
        print(
            '❌ Erreur mise à jour token FCM via Firebase Function: ${response.statusCode}');
        // Fallback: sauvegarde directe dans Firestore
        await _saveFCMTokenDirectlyToFirestore(phone, token);
      }
    } catch (e) {
      print('❌ Erreur mise à jour token FCM via Firebase Function: $e');
      // Fallback: sauvegarde directe dans Firestore
      await _saveFCMTokenDirectlyToFirestore(phone, token);
    }
  }

  /// Sauvegarde directe du token FCM dans Firestore (fallback)
  Future<void> _saveFCMTokenDirectlyToFirestore(
      String phone, String token) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(phone).set({
        'fcm_token': token,
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Token FCM sauvegardé directement dans Firestore');
    } catch (e) {
      print('❌ Erreur sauvegarde directe token FCM: $e');
    }
  }

  /// Envoyer une notification à un utilisateur spécifique
  Future<bool> sendNotificationToUser({
    required String phone,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendNotificationUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification envoyée: ${result['message']}');
        return true;
      } else {
        print('❌ Erreur envoi notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur envoi notification: $e');
      return false;
    }
  }

  /// Envoyer une notification à tous les utilisateurs d'un rôle
  Future<bool> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_sendNotificationToRoleUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': role,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification envoyée au rôle $role: ${result['message']}');
        return true;
      } else {
        print('❌ Erreur envoi notification par rôle: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur envoi notification par rôle: $e');
      return false;
    }
  }

  /// Gérer les messages en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Message reçu en premier plan: ${message.notification?.title}');

    // Afficher une notification locale pour les messages en premier plan
    _showLocalNotification(message);
  }

  /// Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'default',
        'Notifications par défaut',
        channelDescription: 'Canal pour les notifications générales',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title ?? 'Nouvelle notification',
        message.notification?.body ?? '',
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );

      print('✅ Notification locale affichée');
    } catch (e) {
      print('❌ Erreur affichage notification locale: $e');
    }
  }

  /// Gérer les messages en arrière-plan
  void _handleBackgroundMessage(RemoteMessage message) {
    print('📱 Message reçu en arrière-plan: ${message.notification?.title}');

    // Naviguer vers l'écran approprié selon le type de notification
    _handleNotificationNavigation(message);
  }

  /// Gérer le clic sur une notification
  void _handleNotificationClick(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        final type = data['type'];

        print('📱 Notification cliquée de type: $type');

        // Naviguer selon le type de notification
        _handleNotificationNavigation(null, data: data);
      } catch (e) {
        print('❌ Erreur parsing payload notification: $e');
      }
    }
  }

  /// Gérer la navigation selon le type de notification
  void _handleNotificationNavigation(RemoteMessage? message,
      {Map<String, dynamic>? data}) {
    final notificationData = data ?? message?.data;
    final type = notificationData?['type'];

    switch (type) {
      case 'new_order':
        // Naviguer vers la page des commandes (admin)
        print('🆕 Nouvelle commande reçue - Navigation vers notifications');
        _navigationService.navigateToNotifications();
        break;
      case 'order_assigned':
        // Naviguer vers la page de livraison (livreur)
        print('📦 Commande assignée - Navigation vers notifications');
        _navigationService.navigateToNotifications();
        break;
      case 'delivery_status':
        // Naviguer vers la page de suivi (client)
        print(
            '🚚 Mise à jour statut livraison - Navigation vers notifications');
        _navigationService.navigateToNotifications();
        break;
      case 'system_test':
        // Navigation vers la page de notifications pour les tests
        print('🧪 Test système - Navigation vers notifications');
        _navigationService.navigateToNotifications();
        break;
      default:
        // Par défaut, naviguer vers la page de notifications
        print('📱 Notification reçue - Navigation vers notifications');
        _navigationService.navigateToNotifications();
    }
  }

  /// Supprimer le token FCM actuel (déconnexion)
  Future<void> removeCurrentToken() async {
    try {
      await _messaging.deleteToken();
      print('✅ Token FCM supprimé');
    } catch (e) {
      print('❌ Erreur suppression token FCM: $e');
    }
  }

  /// Obtenir le token FCM actuel
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('❌ Erreur récupération token FCM: $e');
      return null;
    }
  }
}
