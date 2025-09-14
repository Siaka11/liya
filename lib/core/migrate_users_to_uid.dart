import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script de migration pour convertir les utilisateurs Firestore vers l'UID Firebase Auth
class UserMigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Migrer tous les utilisateurs existants vers la nouvelle structure
  static Future<void> migrateAllUsers() async {
    try {
      print('🔄 === DÉBUT MIGRATION UTILISATEURS ===');

      // Récupérer tous les utilisateurs existants (par numéro de téléphone)
      final usersSnapshot = await _firestore.collection('users').get();

      print('📊 Nombre d\'utilisateurs à migrer: ${usersSnapshot.docs.length}');

      for (final doc in usersSnapshot.docs) {
        final phoneNumber = doc.id;
        final userData = doc.data();

        print('\n🔍 Migration de l\'utilisateur: $phoneNumber');

        // Vérifier si c'est déjà un UID (nouveau format)
        if (_isValidUID(phoneNumber)) {
          print('✅ Utilisateur déjà au nouveau format (UID)');
          continue;
        }

        // Rechercher l'utilisateur Firebase Auth correspondant
        final firebaseUser = await _findFirebaseUserByPhone(phoneNumber);

        if (firebaseUser != null) {
          print('✅ Utilisateur Firebase Auth trouvé: ${firebaseUser.uid}');

          // Créer le nouveau document avec l'UID
          await _createNewUserDocument(firebaseUser.uid, userData);

          // Supprimer l'ancien document
          await doc.reference.delete();

          print('✅ Migration réussie pour: $phoneNumber → ${firebaseUser.uid}');
        } else {
          print('⚠️ Utilisateur Firebase Auth non trouvé pour: $phoneNumber');
          // Garder l'ancien document pour l'instant
        }
      }

      print('\n✅ === MIGRATION TERMINÉE ===');
    } catch (e) {
      print('❌ Erreur lors de la migration: $e');
    }
  }

  /// Vérifier si une chaîne ressemble à un UID Firebase Auth
  static bool _isValidUID(String id) {
    // Les UIDs Firebase Auth font généralement 28 caractères
    return id.length == 28 && !id.startsWith('+');
  }

  /// Rechercher un utilisateur Firebase Auth par numéro de téléphone
  static Future<User?> _findFirebaseUserByPhone(String phoneNumber) async {
    try {
      // Normaliser le numéro de téléphone
      final normalizedPhone = _normalizePhone(phoneNumber);

      // Rechercher dans la liste des utilisateurs Firebase Auth
      // Note: Cette méthode nécessite l'Admin SDK en production
      // Pour le moment, on retourne null et on gère le cas

      print('🔍 Recherche Firebase Auth pour: $normalizedPhone');

      // TODO: Implémenter la recherche réelle avec Admin SDK
      // Pour l'instant, on retourne null
      return null;
    } catch (e) {
      print('❌ Erreur recherche Firebase Auth: $e');
      return null;
    }
  }

  /// Normaliser un numéro de téléphone
  static String _normalizePhone(String phone) {
    // Supprimer les espaces et caractères spéciaux
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Ajouter le préfixe +225 si nécessaire
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('225')) {
        cleaned = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        cleaned = '+225${cleaned.substring(1)}';
      } else {
        cleaned = '+225$cleaned';
      }
    }

    return cleaned;
  }

  /// Créer un nouveau document utilisateur avec l'UID Firebase Auth
  static Future<void> _createNewUserDocument(
      String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        ...userData,
        'migrated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Nouveau document créé avec UID: $uid');
    } catch (e) {
      print('❌ Erreur création nouveau document: $e');
      rethrow;
    }
  }

  /// Migrer un utilisateur spécifique
  static Future<void> migrateUser(String phoneNumber, String uid) async {
    try {
      print('🔄 Migration de l\'utilisateur: $phoneNumber → $uid');

      // Récupérer les données de l'ancien document
      final oldDoc =
          await _firestore.collection('users').doc(phoneNumber).get();

      if (!oldDoc.exists) {
        print('❌ Ancien document non trouvé: $phoneNumber');
        return;
      }

      final userData = oldDoc.data()!;

      // Créer le nouveau document
      await _createNewUserDocument(uid, userData);

      // Supprimer l'ancien document
      await oldDoc.reference.delete();

      print('✅ Migration réussie: $phoneNumber → $uid');
    } catch (e) {
      print('❌ Erreur migration utilisateur: $e');
    }
  }

  /// Vérifier l'état de la migration
  static Future<void> checkMigrationStatus() async {
    try {
      print('🔍 === VÉRIFICATION ÉTAT MIGRATION ===');

      final usersSnapshot = await _firestore.collection('users').get();
      int oldFormat = 0;
      int newFormat = 0;

      for (final doc in usersSnapshot.docs) {
        if (_isValidUID(doc.id)) {
          newFormat++;
        } else {
          oldFormat++;
        }
      }

      print('📊 Utilisateurs au nouveau format (UID): $newFormat');
      print('📊 Utilisateurs à l\'ancien format (téléphone): $oldFormat');
      print('📊 Total: ${usersSnapshot.docs.length}');

      if (oldFormat == 0) {
        print('✅ Migration complète !');
      } else {
        print('⚠️ Migration incomplète. $oldFormat utilisateurs à migrer.');
      }
    } catch (e) {
      print('❌ Erreur vérification migration: $e');
    }
  }
}
