import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class FCMTokenService {
  static const String _tokenKey = 'fcm_token';
  static const String _deviceIdKey = 'device_id';

  // Singleton pattern
  static final FCMTokenService _instance = FCMTokenService._internal();
  factory FCMTokenService() => _instance;
  FCMTokenService._internal();

  // 1. Récupérer le token FCM
  static Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('📱 Token FCM récupéré: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('❌ Erreur récupération token FCM: $e');
      return null;
    }
  }

  // 2. Générer un ID unique pour l'appareil
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId =
          'device_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  // 3. Enregistrer le token pour l'utilisateur connecté
  static Future<void> registerTokenForUser(String userPhoneNumber) async {
    try {
      final token = await getFCMToken();
      final deviceId = await getDeviceId();

      if (token == null) {
        print('❌ Token FCM non disponible');
        return;
      }

      // Récupérer les tokens existants
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userPhoneNumber)
          .get();

      List<Map<String, dynamic>> existingTokens = [];
      if (userDoc.exists) {
        existingTokens = List<Map<String, dynamic>>.from(
            userDoc.data()?['fcm_tokens'] ?? []);
      }

      // Vérifier si le token existe déjà
      final tokenExists = existingTokens.any((t) => t['device_id'] == deviceId);

      if (!tokenExists) {
        // Ajouter le nouveau token
        existingTokens.add({
          'token': token,
          'device_id': deviceId,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app_version': '1.0.0', // À récupérer dynamiquement
          'last_used': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
        });

        // Mettre à jour Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userPhoneNumber)
            .update({
          'fcm_tokens': existingTokens,
        });

        print('✅ Token FCM enregistré pour $userPhoneNumber');
      } else {
        // Mettre à jour le token existant
        final tokenIndex =
            existingTokens.indexWhere((t) => t['device_id'] == deviceId);
        if (tokenIndex != -1) {
          existingTokens[tokenIndex]['token'] = token;
          existingTokens[tokenIndex]['last_used'] =
              FieldValue.serverTimestamp();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userPhoneNumber)
              .update({
            'fcm_tokens': existingTokens,
          });

          print('✅ Token FCM mis à jour pour $userPhoneNumber');
        }
      }
    } catch (e) {
      print('❌ Erreur enregistrement token: $e');
    }
  }

  // 4. Supprimer le token lors de la déconnexion
  static Future<void> unregisterTokenForUser(String userPhoneNumber) async {
    try {
      final deviceId = await getDeviceId();

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userPhoneNumber)
          .get();

      if (userDoc.exists) {
        List<Map<String, dynamic>> existingTokens =
            List<Map<String, dynamic>>.from(
                userDoc.data()?['fcm_tokens'] ?? []);

        // Supprimer le token de cet appareil
        existingTokens.removeWhere((t) => t['device_id'] == deviceId);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userPhoneNumber)
            .update({
          'fcm_tokens': existingTokens,
        });

        print('✅ Token FCM supprimé pour $userPhoneNumber');
      }
    } catch (e) {
      print('❌ Erreur suppression token: $e');
    }
  }

  // 5. Nettoyer les tokens invalides
  static Future<void> cleanupInvalidTokens() async {
    try {
      // Récupérer tous les utilisateurs avec des tokens
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('fcm_tokens', isGreaterThan: []).get();

      for (final userDoc in usersQuery.docs) {
        final userData = userDoc.data();
        final tokens =
            List<Map<String, dynamic>>.from(userData['fcm_tokens'] ?? []);

        // Supprimer les tokens anciens (plus de 30 jours)
        final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
        tokens.removeWhere((token) {
          final lastUsed = token['last_used']?.toDate();
          return lastUsed != null && lastUsed.isBefore(thirtyDaysAgo);
        });

        if (tokens.length != userData['fcm_tokens'].length) {
          await userDoc.reference.update({'fcm_tokens': tokens});
          print('🧹 Tokens nettoyés pour ${userData['name']}');
        }
      }
    } catch (e) {
      print('❌ Erreur nettoyage tokens: $e');
    }
  }
}
