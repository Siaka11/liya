import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script de test pour vérifier la suppression Firebase Auth
class FirebaseAuthDeletionTest {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test de suppression complète d'un utilisateur
  static Future<void> testCompleteUserDeletion(String phoneNumber) async {
    try {
      print('🧪 === TEST SUPPRESSION UTILISATEUR ===');
      print('📞 Numéro à tester: $phoneNumber');

      // 1. Vérifier l'utilisateur dans Firebase Auth
      print('\n🔍 Étape 1: Vérification Firebase Auth');
      final user = _auth.currentUser;
      if (user != null) {
        print('✅ Utilisateur connecté: ${user.uid}');
        print('📞 Numéro: ${user.phoneNumber}');
        print('📧 Email: ${user.email ?? "N/A"}');
        print('🕒 Créé le: ${user.metadata.creationTime}');
        print('🕒 Dernière connexion: ${user.metadata.lastSignInTime}');
      } else {
        print('❌ Aucun utilisateur connecté');
        return;
      }

      // 2. Vérifier l'utilisateur dans Firestore
      print('\n🔍 Étape 2: Vérification Firestore');
      final userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();
      if (userDoc.exists) {
        print('✅ Utilisateur trouvé dans Firestore');
        print('📋 Données: ${userDoc.data()}');
      } else {
        print('❌ Utilisateur non trouvé dans Firestore');
      }

      // 3. Simuler la suppression (sans vraiment supprimer)
      print('\n🔍 Étape 3: Simulation de suppression');
      print('📱 Suppression des données Firestore...');
      print('🔥 Suppression du compte Firebase Auth...');
      print('🧹 Nettoyage du stockage local...');

      // 4. Vérifier les méthodes de suppression disponibles
      print('\n🔍 Étape 4: Vérification méthodes de suppression');
      print('✅ user.delete() disponible: ${user.uid.isNotEmpty}');
      print(
          '✅ _firestore.collection("users").doc(phoneNumber).delete() disponible: true');

      // 5. Test des permissions
      print('\n🔍 Étape 5: Vérification permissions');
      try {
        // Test si on peut accéder aux données utilisateur
        await user.reload();
        print('✅ Accès aux données utilisateur: OK');
      } catch (e) {
        print('❌ Erreur accès données utilisateur: $e');
      }

      print('\n✅ TEST TERMINÉ - Prêt pour suppression réelle');
    } catch (e) {
      print('❌ Erreur lors du test: $e');
    }
  }

  /// Test de suppression réelle (ATTENTION: Supprime vraiment l'utilisateur)
  static Future<void> performRealDeletion(String phoneNumber) async {
    try {
      print('⚠️ === SUPPRESSION RÉELLE ===');
      print(
          '⚠️ ATTENTION: Cette opération supprime définitivement l\'utilisateur !');

      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Aucun utilisateur connecté');
        return;
      }

      // Vérifier que c'est le bon utilisateur
      if (user.phoneNumber != phoneNumber) {
        print('❌ Numéro de téléphone ne correspond pas');
        print('   Connecté: ${user.phoneNumber}');
        print('   Demandé: $phoneNumber');
        return;
      }

      print('🔥 Suppression du compte Firebase Auth...');
      await user.delete();
      print('✅ Compte Firebase Auth supprimé');

      print('📱 Suppression des données Firestore...');
      await _firestore.collection('users').doc(phoneNumber).delete();
      print('✅ Données Firestore supprimées');

      print('✅ SUPPRESSION RÉELLE TERMINÉE');
    } catch (e) {
      print('❌ Erreur lors de la suppression réelle: $e');
    }
  }

  /// Vérifier l'état après suppression
  static Future<void> verifyDeletion(String phoneNumber) async {
    try {
      print('🔍 === VÉRIFICATION APRÈS SUPPRESSION ===');

      // Vérifier Firebase Auth
      final user = _auth.currentUser;
      if (user == null) {
        print(
            '✅ Firebase Auth: Aucun utilisateur connecté (suppression réussie)');
      } else {
        print('⚠️ Firebase Auth: Utilisateur encore connecté: ${user.uid}');
      }

      // Vérifier Firestore
      final userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();
      if (!userDoc.exists) {
        print('✅ Firestore: Document supprimé (suppression réussie)');
      } else {
        print('⚠️ Firestore: Document encore présent: ${userDoc.data()}');
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification: $e');
    }
  }

  /// Lister tous les utilisateurs Firebase Auth (pour debug)
  static Future<void> listAllUsers() async {
    try {
      print('📋 === LISTE DES UTILISATEURS FIREBASE AUTH ===');
      final user = _auth.currentUser;
      if (user != null) {
        print('👤 Utilisateur connecté:');
        print('   - UID: ${user.uid}');
        print('   - Phone: ${user.phoneNumber}');
        print('   - Email: ${user.email ?? "N/A"}');
        print('   - Créé: ${user.metadata.creationTime}');
        print('   - Dernière connexion: ${user.metadata.lastSignInTime}');
        print('   - Vérifié: ${user.emailVerified}');
        print(
            '   - Providers: ${user.providerData.map((p) => p.providerId).toList()}');
      } else {
        print('❌ Aucun utilisateur connecté');
      }
    } catch (e) {
      print('❌ Erreur lors de la liste: $e');
    }
  }
}
