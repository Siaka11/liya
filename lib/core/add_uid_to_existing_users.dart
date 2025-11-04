import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script pour ajouter le champ 'uid' aux utilisateurs existants
class AddUidToExistingUsers {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Ajouter le champ 'uid' à tous les utilisateurs existants
  static Future<void> addUidToAllUsers() async {
    try {
      print('🔄 === AJOUT DU CHAMP UID AUX UTILISATEURS EXISTANTS ===');

      // Récupérer tous les utilisateurs existants
      final usersSnapshot = await _firestore.collection('users').get();

      print(
          '📊 Nombre d\'utilisateurs à traiter: ${usersSnapshot.docs.length}');

      int updated = 0;
      int skipped = 0;

      for (final doc in usersSnapshot.docs) {
        final phoneNumber = doc.id;
        final userData = doc.data();

        print('\n🔍 Traitement de l\'utilisateur: $phoneNumber');

        // Vérifier si le champ 'uid' existe déjà
        if (userData.containsKey('uid') && userData['uid'] != null) {
          print('✅ Champ UID déjà présent: ${userData['uid']}');
          skipped++;
          continue;
        }

        // Rechercher l'utilisateur Firebase Auth correspondant
        final firebaseUser = await _findFirebaseUserByPhone(phoneNumber);

        if (firebaseUser != null) {
          print('✅ Utilisateur Firebase Auth trouvé: ${firebaseUser.uid}');

          // Ajouter le champ 'uid' au document
          await doc.reference.update({
            'uid': firebaseUser.uid,
            'updated_at': FieldValue.serverTimestamp(),
          });

          updated++;
          print('✅ Champ UID ajouté: ${firebaseUser.uid}');
        } else {
          print('⚠️ Utilisateur Firebase Auth non trouvé pour: $phoneNumber');
          skipped++;
        }
      }

      print('\n✅ === TRAITEMENT TERMINÉ ===');
      print('📊 Utilisateurs mis à jour: $updated');
      print('📊 Utilisateurs ignorés: $skipped');
      print('📊 Total: ${usersSnapshot.docs.length}');
    } catch (e) {
      print('❌ Erreur lors du traitement: $e');
    }
  }

  /// Rechercher un utilisateur Firebase Auth par numéro de téléphone
  static Future<User?> _findFirebaseUserByPhone(String phoneNumber) async {
    try {
      // Normaliser le numéro de téléphone
      final normalizedPhone = _normalizePhone(phoneNumber);

      print('🔍 Recherche Firebase Auth pour: $normalizedPhone');

      // Note: Cette méthode nécessite l'Admin SDK en production
      // Pour le moment, on retourne null et on gère le cas

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

  /// Ajouter le champ 'uid' à un utilisateur spécifique
  static Future<void> addUidToUser(String phoneNumber, String uid) async {
    try {
      print('🔄 Ajout du champ UID pour: $phoneNumber → $uid');

      final userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();

      if (!userDoc.exists) {
        print('❌ Document utilisateur non trouvé: $phoneNumber');
        return;
      }

      // Ajouter le champ 'uid'
      await userDoc.reference.update({
        'uid': uid,
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Champ UID ajouté avec succès: $phoneNumber → $uid');
    } catch (e) {
      print('❌ Erreur ajout UID: $e');
    }
  }

  /// Vérifier l'état des champs UID
  static Future<void> checkUidStatus() async {
    try {
      print('🔍 === VÉRIFICATION ÉTAT DES CHAMPS UID ===');

      final usersSnapshot = await _firestore.collection('users').get();
      int withUid = 0;
      int withoutUid = 0;

      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        if (userData.containsKey('uid') && userData['uid'] != null) {
          withUid++;
        } else {
          withoutUid++;
        }
      }

      print('📊 Utilisateurs avec UID: $withUid');
      print('📊 Utilisateurs sans UID: $withoutUid');
      print('📊 Total: ${usersSnapshot.docs.length}');

      if (withoutUid == 0) {
        print('✅ Tous les utilisateurs ont un champ UID !');
      } else {
        print('⚠️ $withoutUid utilisateurs sans champ UID.');
      }
    } catch (e) {
      print('❌ Erreur vérification UID: $e');
    }
  }
}

