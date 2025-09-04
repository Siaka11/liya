import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service de gestion du profil utilisateur
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mettre à jour le nom de l'utilisateur
  Future<void> updateUserName(String userId, String newName) async {
    try {
      print('📝 Mise à jour du nom utilisateur: $newName');

      // Mettre à jour dans Firestore
      await _firestore.collection('users').doc(userId).update({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le displayName dans Firebase Auth si l'utilisateur est connecté
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.updateDisplayName(newName);
        print('✅ Nom mis à jour dans Firebase Auth');
      }

      print('✅ Nom utilisateur mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur mise à jour nom: $e');
      rethrow;
    }
  }

  /// Mettre à jour le prénom de l'utilisateur
  Future<void> updateUserLastName(String userId, String newLastName) async {
    try {
      print('📝 Mise à jour du prénom utilisateur: $newLastName');

      await _firestore.collection('users').doc(userId).update({
        'lastName': newLastName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Prénom utilisateur mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur mise à jour prénom: $e');
      rethrow;
    }
  }

  /// Mettre à jour l'email de l'utilisateur
  Future<void> updateUserEmail(String userId, String newEmail) async {
    try {
      print('📝 Mise à jour de l\'email utilisateur: $newEmail');

      // Mettre à jour dans Firestore
      await _firestore.collection('users').doc(userId).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour l'email dans Firebase Auth si l'utilisateur est connecté
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.updateEmail(newEmail);
        print('✅ Email mis à jour dans Firebase Auth');
      }

      print('✅ Email utilisateur mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur mise à jour email: $e');
      rethrow;
    }
  }

  /// Mettre à jour le numéro de téléphone de l'utilisateur
  Future<void> updateUserPhoneNumber(
      String userId, String newPhoneNumber) async {
    try {
      print('📝 Mise à jour du numéro de téléphone: $newPhoneNumber');

      await _firestore.collection('users').doc(userId).update({
        'phoneNumber': newPhoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Numéro de téléphone mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur mise à jour numéro: $e');
      rethrow;
    }
  }

  /// Mettre à jour l'adresse de l'utilisateur
  Future<void> updateUserAddress(String userId, String newAddress) async {
    try {
      print('📝 Mise à jour de l\'adresse utilisateur: $newAddress');

      await _firestore.collection('users').doc(userId).update({
        'address': newAddress,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Adresse utilisateur mise à jour avec succès');
    } catch (e) {
      print('❌ Erreur mise à jour adresse: $e');
      rethrow;
    }
  }

  /// Mettre à jour plusieurs champs du profil en une seule fois
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      print('📝 Mise à jour multiple du profil utilisateur');

      // Ajouter le timestamp de mise à jour
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updates);

      // Mettre à jour Firebase Auth si nécessaire
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        if (updates.containsKey('name')) {
          await currentUser.updateDisplayName(updates['name']);
        }
        if (updates.containsKey('email')) {
          await currentUser.updateEmail(updates['email']);
        }
      }

      print('✅ Profil utilisateur mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      rethrow;
    }
  }

  /// Récupérer le profil complet de l'utilisateur
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('📖 Récupération du profil utilisateur: $userId');

      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        print('✅ Profil utilisateur récupéré avec succès');
        return data;
      } else {
        print('⚠️ Profil utilisateur non trouvé');
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération profil: $e');
      rethrow;
    }
  }

  /// Vérifier si un email est déjà utilisé
  Future<bool> isEmailAlreadyUsed(String email, {String? excludeUserId}) async {
    try {
      print('🔍 Vérification disponibilité email: $email');

      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Si on exclut un utilisateur (pour les mises à jour), vérifier qu'il n'y a pas d'autres utilisateurs avec cet email
      if (excludeUserId != null) {
        final isUsed = query.docs.any((doc) => doc.id != excludeUserId);
        print('🔍 Email ${isUsed ? "déjà utilisé" : "disponible"}');
        return isUsed;
      }

      final isUsed = query.docs.isNotEmpty;
      print('🔍 Email ${isUsed ? "déjà utilisé" : "disponible"}');
      return isUsed;
    } catch (e) {
      print('❌ Erreur vérification email: $e');
      return false; // En cas d'erreur, considérer comme disponible
    }
  }

  /// Vérifier si un numéro de téléphone est déjà utilisé
  Future<bool> isPhoneNumberAlreadyUsed(String phoneNumber,
      {String? excludeUserId}) async {
    try {
      print('🔍 Vérification disponibilité numéro: $phoneNumber');

      QuerySnapshot query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      // Si on exclut un utilisateur (pour les mises à jour), vérifier qu'il n'y a pas d'autres utilisateurs avec ce numéro
      if (excludeUserId != null) {
        final isUsed = query.docs.any((doc) => doc.id != excludeUserId);
        print('🔍 Numéro ${isUsed ? "déjà utilisé" : "disponible"}');
        return isUsed;
      }

      final isUsed = query.docs.isNotEmpty;
      print('🔍 Numéro ${isUsed ? "déjà utilisé" : "disponible"}');
      return isUsed;
    } catch (e) {
      print('❌ Erreur vérification numéro: $e');
      return false; // En cas d'erreur, considérer comme disponible
    }
  }

  /// Valider le format de l'email
  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Valider le format du numéro de téléphone
  bool isValidPhoneNumber(String phoneNumber) {
    // Format ivoirien: commence par 0 suivi de 9 chiffres
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  /// Valider le nom/prénom
  bool isValidName(String name) {
    // Au moins 2 caractères, pas de chiffres
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]{2,}$');
    return nameRegex.hasMatch(name.trim());
  }
}
