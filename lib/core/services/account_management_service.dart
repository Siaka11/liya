import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/core/services/fcm_service.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/modules/auth/auth_page.dart';

class AccountManagementService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Affiche le menu de gestion de compte avec modal bottom sheet
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                const Text(
                  'Gérer votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choisir une action',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton Se déconnecter
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Bouton Supprimer le compte
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeleteConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Supprimer le compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Bouton Annuler
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Espace en bas pour éviter les problèmes de clavier
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Déconnexion de l'utilisateur
  static Future<void> _logout(BuildContext context) async {
    try {
      print('🚪 Déconnexion de l\'utilisateur...');

      // Supprimer le token FCM avant la déconnexion
      try {
        await FCMService().removeCurrentToken();
        print('🗑️ Token FCM supprimé');
      } catch (e) {
        print('⚠️ Erreur suppression token FCM: $e');
      }

      // Déconnexion Firebase Auth
      await _auth.signOut();
      print('✅ Déconnexion Firebase Auth réussie');

      // Nettoyer les données locales
      await _clearLocalData();

      // Rediriger vers la page d'authentification
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }

      // Afficher un message de confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Déconnexion réussie'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Afficher la confirmation de suppression avec modal bottom sheet
  static void _showDeleteConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône d'avertissement
                const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Supprimer le compte',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Êtes-vous sûr de vouloir supprimer définitivement votre compte ?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cette action est irréversible et supprimera toutes vos données.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton Supprimer définitivement
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteAccount(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Supprimer définitivement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Bouton Annuler
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Espace en bas
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Supprimer le compte de l'utilisateur
  static Future<void> _deleteAccount(BuildContext context) async {
    try {
      print('🗑️ === DÉBUT SUPPRESSION COMPTE ===');

      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Aucun utilisateur connecté');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Aucun utilisateur connecté'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final phoneNumber = user.phoneNumber;
      if (phoneNumber == null) {
        print('❌ Numéro de téléphone non trouvé');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Numéro de téléphone non trouvé'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('🔐 Tentative de suppression du compte Firebase Auth...');

      // Supprimer les données Firestore en utilisant le numéro de téléphone
      await _deleteUserData(phoneNumber);

      // Supprimer le token FCM avant de supprimer le compte
      try {
        await FCMService().removeCurrentToken();
        print('🗑️ Token FCM supprimé');
      } catch (e) {
        print('⚠️ Erreur suppression token FCM: $e');
      }

      // Supprimer le compte Firebase Auth
      try {
        await user.delete();
        print('🔥 Compte Firebase Auth supprimé avec succès');
      } catch (e) {
        print('⚠️ Erreur suppression Firebase Auth: $e');

        if (e.toString().contains('requires-recent-login')) {
          print('⚠️ Ré-authentification requise pour Firebase Auth');

          // Afficher un message et rediriger vers l'authentification
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Ré-authentification requise pour supprimer le compte Firebase Auth. Vous allez être redirigé vers la page de connexion.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );

            // Attendre un peu avant la redirection
            await Future.delayed(const Duration(milliseconds: 500));
          }

          // Déconnexion et redirection
          await _auth.signOut();
          await _clearLocalData();

          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthPage()),
              (route) => false,
            );
          }
          return;
        }

        // Autre erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Nettoyer les données locales
      await _clearLocalData();

      // Afficher le message de succès et rediriger
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Compte supprimé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Attendre un peu avant la redirection
        await Future.delayed(const Duration(milliseconds: 500));

        // Rediriger vers la page d'authentification
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthPage()),
            (route) => false,
          );
        }
      }

      print('✅ === SUPPRESSION COMPTE TERMINÉE ===');
    } catch (e) {
      print('❌ Erreur lors de la suppression du compte: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Supprimer les données utilisateur de Firestore par numéro de téléphone
  static Future<void> _deleteUserData(String phoneNumber) async {
    try {
      print(
          '🗑️ Suppression des données Firestore par téléphone: $phoneNumber');

      // Supprimer le document utilisateur principal
      await _firestore.collection('users').doc(phoneNumber).delete();
      print('✅ Document utilisateur supprimé par téléphone');

      // Supprimer les commandes associées (optionnel)
      try {
        final ordersQuery = await _firestore
            .collection('orders')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        for (var doc in ordersQuery.docs) {
          await doc.reference.delete();
        }

        // Supprimer les favoris associés (optionnel)
        final favoritesQuery = await _firestore
            .collection('favorites')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        for (var doc in favoritesQuery.docs) {
          await doc.reference.delete();
        }

        // Supprimer les colis associés
        final parcelsQuery = await _firestore
            .collection('parcels')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        for (var doc in parcelsQuery.docs) {
          await doc.reference.delete();
        }

        // Supprimer les tokens FCM associés
        final fcmTokensQuery = await _firestore
            .collection('users')
            .doc(phoneNumber)
            .collection('fcm_tokens')
            .get();

        for (var doc in fcmTokensQuery.docs) {
          await doc.reference.delete();
        }

        // Supprimer les notifications associées
        final notificationsQuery = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: phoneNumber)
            .get();

        for (var doc in notificationsQuery.docs) {
          await doc.reference.delete();
        }

        // Supprimer les autres données associées si nécessaire
        // Par exemple, les préférences, l'historique, etc.
      } catch (e) {
        print('Erreur lors de la suppression des données Firestore: $e');
        // On continue même si la suppression des données échoue
      }
    } catch (e) {
      print('❌ Erreur suppression données Firestore par téléphone: $e');
      // On continue même si la suppression des données échoue
    }
  }

  /// Nettoyer toutes les données locales
  static Future<void> _clearLocalData() async {
    try {
      // Nettoyer SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Nettoyer le stockage local personnalisé
      final localStorage = LocalStorageFactory();
      await localStorage.clearUserDetails();
    } catch (e) {
      print('Erreur lors du nettoyage des données locales: $e');
    }
  }
}
