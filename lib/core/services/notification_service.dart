import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    print('🔔 Initialisation du service de notifications...');

    try {
      // Demander les permissions
      await _requestPermissions();

      // Configurer les notifications locales
      await _configureLocalNotifications();

      // Configurer Firebase Messaging
      await _configureFirebaseMessaging();

      print('✅ NotificationService initialisé avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des notifications: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    print('🔐 Demande des permissions de notifications...');

    // Demander les permissions iOS
    if (Platform.isIOS) {
      final status = await Permission.notification.request();
      print('🍎 iOS - Permission notifications: $status');

      // Demander les permissions Firebase
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('🔑 Firebase - Permission: ${settings.authorizationStatus}');
    }

    // Demander les permissions Android
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      print('🤖 Android - Permission notifications: $status');
    }
  }

  static Future<void> _configureLocalNotifications() async {
    print('📱 Configuration des notifications locales...');

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
        print('📱 Notification locale reçue: ${response.payload}');
      },
    );
  }

  static Future<void> _configureFirebaseMessaging() async {
    print('🔥 Configuration Firebase Messaging...');

    // Configurer les handlers pour les notifications en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configurer les handlers pour les notifications au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          '📨 Notification reçue au premier plan: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Configurer les handlers pour les notifications quand l'app est ouverte
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App ouverte via notification: ${message.notification?.title}');
    });

    // Obtenir le token FCM
    try {
      final token = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $token');

      // Sauvegarder le token dans Firestore (optionnel)
      // await _saveTokenToFirestore(token);
    } catch (e) {
      print('❌ Erreur lors de la récupération du token FCM: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'liya_channel',
      'Liya Notifications',
      channelDescription: 'Notifications pour l\'application Liya',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
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
      message.hashCode,
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('📱 Affichage notification locale: $title');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'liya_channel',
      'Liya Notifications',
      channelDescription: 'Notifications pour l\'application Liya',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
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
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('🔑 Token récupéré: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('📡 Abonné au topic: $topic');
    } catch (e) {
      print('❌ Erreur lors de l\'abonnement au topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('📡 Désabonné du topic: $topic');
    } catch (e) {
      print('❌ Erreur lors du désabonnement du topic: $e');
    }
  }
}

// Handler pour les notifications en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Notification en arrière-plan: ${message.notification?.title}');

  // Afficher une notification locale même en arrière-plan
  await NotificationService.showLocalNotification(
    title: message.notification?.title ?? 'Nouvelle notification',
    body: message.notification?.body ?? '',
    payload: message.data.toString(),
  );
}
