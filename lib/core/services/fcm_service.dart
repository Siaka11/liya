import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:liya/core/singletons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../local_storage_factory.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  /// Initialiser FCM et demander les permissions
  Future<void> initialize() async {
    try {
      print('🚀 === DÉBUT INITIALISATION FCM ===');

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

      print('📱 Permissions FCM: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permissions FCM accordées');

        // Configurer les handlers pour les notifications en arrière-plan
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        // Configurer les handlers pour les notifications en premier plan
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Configurer les handlers pour les notifications quand l'app est ouverte
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        print('✅ FCM initialisé avec succès');
        print('⏳ Token FCM sera obtenu après authentification');
      } else {
        print('❌ Permissions FCM refusées: ${settings.authorizationStatus}');
      }

      print('🚀 === FIN INITIALISATION FCM ===');
    } catch (e) {
      print('❌ Erreur initialisation FCM: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Initialiser FCM après l'authentification de l'utilisateur
  Future<void> initializeAfterAuth() async {
    try {
      print('🔐 === DÉBUT INITIALISATION FCM APRÈS AUTH ===');

      // Obtenir le token FCM maintenant que l'utilisateur est authentifié
      await _getAndSaveFCMToken();

      print('🔐 === FIN INITIALISATION FCM APRÈS AUTH ===');
    } catch (e) {
      print('❌ Erreur initialisation FCM après authentification: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Obtenir et sauvegarder le token FCM
  Future<void> _getAndSaveFCMToken() async {
    try {
      print('🔍 Début obtention token FCM...');
      final token = await _messaging.getToken();

      if (token != null) {
        print('📱 Token FCM obtenu avec succès: ${token.substring(0, 20)}...');
        print('📱 Token complet: $token');

        await _saveFCMTokenToFirestore(token);
        await _saveFCMTokenLocally(token);
      } else {
        print('❌ Impossible d\'obtenir le token FCM - token est null');
      }
    } catch (e) {
      print('❌ Erreur obtention token FCM: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Sauvegarder le token FCM dans Firestore
  Future<void> _saveFCMTokenToFirestore(String token) async {
    try {
      print('💾 === DÉBUT SAUVEGARDE TOKEN FCM ===');

      // Essayer d'abord avec Firebase Auth
      final currentUser = _authService.currentUser;
      print('🔍 Utilisateur Firebase Auth: ${currentUser?.phoneNumber}');

      String? phoneNumber;

      if (currentUser?.phoneNumber != null) {
        phoneNumber = currentUser!.phoneNumber!;
      } else {
        // Si pas d'utilisateur Firebase Auth, essayer de récupérer depuis LocalStorage
        print('🔍 Tentative de récupération depuis LocalStorage...');
        try {
          final localStorage = LocalStorageFactory();
          final userDetails = localStorage.getUserDetails();
          if (userDetails.isNotEmpty) {
            final userJson = jsonDecode(userDetails) as Map<String, dynamic>;
            phoneNumber = userJson['phoneNumber'] as String?;
            print('🔍 Numéro trouvé dans LocalStorage: $phoneNumber');
          }
        } catch (e) {
          print('❌ Erreur récupération LocalStorage: $e');
        }
      }

      if (phoneNumber != null) {
        final firestorePhone =
            _authService.normalizePhoneForFirestore(phoneNumber);
        print('🔍 Numéro Firestore normalisé: $firestorePhone');

        // Vérifier si l'utilisateur existe dans Firestore
        final userDoc =
            await _firestore.collection('users').doc(firestorePhone).get();
        print('🔍 Document utilisateur existe: ${userDoc.exists}');

        if (userDoc.exists) {
          // Récupérer les tokens existants
          final userData = userDoc.data()!;
          final existingTokens =
              List<String>.from(userData['fcm_tokens'] ?? []);
          print('🔍 Tokens existants: $existingTokens');

          // Ajouter le nouveau token s'il n'existe pas déjà
          if (!existingTokens.contains(token)) {
            existingTokens.add(token);
            print('🔍 Nouveau token ajouté: ${token.substring(0, 20)}...');
          } else {
            print('🔍 Token déjà présent, pas d\'ajout nécessaire');
          }

          // Limiter à 5 tokens maximum (pour éviter une liste trop longue)
          if (existingTokens.length > 5) {
            existingTokens.removeRange(0, existingTokens.length - 5);
            print('🔍 Liste limitée à 5 tokens maximum');
          }

          // Mettre à jour Firestore avec la nouvelle liste
          await _firestore.collection('users').doc(firestorePhone).update({
            'fcm_tokens': existingTokens,
            'last_fcm_token_update': FieldValue.serverTimestamp(),
          });

          print('✅ Token FCM sauvegardé dans Firestore pour: $firestorePhone');
          print('🔍 Tokens finaux: $existingTokens');
        } else {
          print('❌ Utilisateur non trouvé dans Firestore: $firestorePhone');
          print('💡 Tentative de création du document utilisateur...');

          // Créer le document utilisateur avec le token FCM
          await _firestore.collection('users').doc(firestorePhone).set({
            'phoneNumber': firestorePhone,
            'fcm_tokens': [token],
            'last_fcm_token_update': FieldValue.serverTimestamp(),
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

          print(
              '✅ Document utilisateur créé avec token FCM pour: $firestorePhone');
        }
      } else {
        print(
            '⚠️ Aucun numéro de téléphone trouvé, sauvegarde du token en attente...');
        // Sauvegarder le token localement pour une utilisation ultérieure
        await _saveFCMTokenLocally(token);
      }

      print('💾 === FIN SAUVEGARDE TOKEN FCM ===');
    } catch (e) {
      print('❌ Erreur sauvegarde token FCM dans Firestore: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Sauvegarder le token FCM localement
  Future<void> _saveFCMTokenLocally(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('✅ Token FCM sauvegardé localement');
    } catch (e) {
      print('❌ Erreur sauvegarde token FCM local: $e');
    }
  }

  /// Envoyer une notification à un utilisateur spécifique
  Future<void> sendNotificationToUser({
    required String userPhoneNumber,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final firestorePhone =
          _authService.normalizePhoneForFirestore(userPhoneNumber);

      // Récupérer les tokens FCM de l'utilisateur
      final userDoc =
          await _firestore.collection('users').doc(firestorePhone).get();
      if (!userDoc.exists) {
        print('❌ Utilisateur non trouvé: $firestorePhone');
        return;
      }

      final userData = userDoc.data()!;
      final fcmTokens = List<String>.from(userData['fcm_tokens'] ?? []);

      if (fcmTokens.isEmpty) {
        print('⚠️ Aucun token FCM trouvé pour l\'utilisateur: $firestorePhone');
        return;
      }

      print(
          '📤 Envoi notification à ${fcmTokens.length} appareil(s) pour: $firestorePhone');

      // Envoyer la notification à tous les appareils de l'utilisateur
      for (String token in fcmTokens) {
        await _sendNotificationToToken(
          token: token,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      print('❌ Erreur envoi notification: $e');
    }
  }

  /// Envoyer une notification à un token spécifique
  Future<void> _sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Ici, tu devras implémenter l'envoi via ton serveur ou Firebase Functions
      // Pour l'instant, on simule l'envoi
      print('📤 Notification envoyée à: ${token.substring(0, 20)}...');
      print('   Titre: $title');
      print('   Corps: $body');
      print('   Données: $data');

      // TODO: Implémenter l'envoi réel via HTTP ou Firebase Functions
      // await http.post(
      //   Uri.parse('https://fcm.googleapis.com/fcm/send'),
      //   headers: {
      //     'Authorization': 'key=YOUR_SERVER_KEY',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'to': token,
      //     'notification': {
      //       'title': title,
      //       'body': body,
      //     },
      //     'data': data,
      //   }),
      // );
    } catch (e) {
      print('❌ Erreur envoi notification au token: $e');
    }
  }

  /// Envoyer une notification à tous les utilisateurs d'un rôle spécifique
  Future<void> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print(
          '📤 Envoi notification à tous les utilisateurs avec le rôle: $role');

      // Récupérer tous les utilisateurs avec le rôle spécifié
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final fcmTokens = List<String>.from(userData['fcm_tokens'] ?? []);

        if (fcmTokens.isNotEmpty) {
          print(
              '📤 Envoi à ${fcmTokens.length} appareil(s) pour: ${userDoc.id}');

          for (String token in fcmTokens) {
            await _sendNotificationToToken(
              token: token,
              title: title,
              body: body,
              data: data,
            );
          }
        }
      }
    } catch (e) {
      print('❌ Erreur envoi notification par rôle: $e');
    }
  }

  /// Gérer les notifications en arrière-plan
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print(
        '📱 Notification reçue en arrière-plan: ${message.notification?.title}');
    print('📱 Données: ${message.data}');
  }

  /// Gérer les notifications en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    print(
        '📱 Notification reçue en premier plan: ${message.notification?.title}');
    print('📱 Données: ${message.data}');

    // Ici tu peux afficher une notification locale ou mettre à jour l'UI
    // _showLocalNotification(message);
  }

  /// Gérer les notifications quand l'app est ouverte
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 App ouverte via notification: ${message.notification?.title}');
    print('📱 Données: ${message.data}');

    // Ici tu peux naviguer vers une page spécifique selon les données
    // _navigateToPage(message.data);
  }

  /// Nettoyer les tokens FCM obsolètes
  Future<void> cleanupOldTokens() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser?.phoneNumber != null) {
        final firestorePhone =
            _authService.normalizePhoneForFirestore(currentUser!.phoneNumber!);
        final localToken = await _getLocalFCMToken();

        if (localToken != null) {
          // Supprimer les tokens obsolètes (sauf le token local)
          await _firestore.collection('users').doc(firestorePhone).update({
            'fcm_tokens': [localToken], // Garder seulement le token actuel
          });
          print('🧹 Tokens FCM nettoyés pour: $firestorePhone');
        }
      }
    } catch (e) {
      print('❌ Erreur nettoyage tokens FCM: $e');
    }
  }

  /// Supprimer le token FCM actuel lors de la déconnexion
  Future<void> removeCurrentToken() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser?.phoneNumber != null) {
        final firestorePhone =
            _authService.normalizePhoneForFirestore(currentUser!.phoneNumber!);
        final localToken = await _getLocalFCMToken();

        if (localToken != null) {
          // Supprimer le token actuel de la liste
          final userDoc =
              await _firestore.collection('users').doc(firestorePhone).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final existingTokens =
                List<String>.from(userData['fcm_tokens'] ?? []);
            existingTokens.remove(localToken);

            await _firestore.collection('users').doc(firestorePhone).update({
              'fcm_tokens': existingTokens,
              'last_fcm_token_update': FieldValue.serverTimestamp(),
            });

            print('🗑️ Token FCM supprimé pour: $firestorePhone');
          }
        }

        // Supprimer le token local
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('fcm_token');
        print('🗑️ Token FCM local supprimé');
      }
    } catch (e) {
      print('❌ Erreur suppression token FCM: $e');
    }
  }

  /// Obtenir le token FCM local
  Future<String?> _getLocalFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('❌ Erreur récupération token FCM local: $e');
      return null;
    }
  }
}
