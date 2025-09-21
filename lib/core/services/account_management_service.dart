import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/services/fcm_service.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/modules/auth/presentation/pages/delete_account_page.dart';
import 'package:liya/core/constants/error_messages.dart';

class AccountManagementService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Affiche le menu de déconnexion avec modal bottom sheet (joli et rapide)
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
                  'Que souhaitez-vous faire ?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                // Bouton Déconnexion
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
                      _navigateToDeleteAccountPage(context);
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
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Navigation vers la page dédiée de suppression de compte
  static void _navigateToDeleteAccountPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeleteAccountPage(),
        fullscreenDialog: true,
      ),
    );
  }

  /// Déconnexion de l'utilisateur
  static Future<void> _logout(BuildContext context) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Déconnexion Firebase Auth
      await _auth.signOut();

      // Nettoyer le stockage local
      await _clearLocalData();

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Déconnexion réussie'),
          backgroundColor: Colors.green,
        ),
      );

      // Rediriger vers la page de connexion
      singleton<AppRouter>().replace(const AuthRoute());
    } catch (e) {
      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(ErrorMessages.logoutFailed),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Suppression du compte utilisateur
  static Future<void> deleteAccount(BuildContext context) async {
    // Sauvegarder le contexte et les données avant l'opération asynchrone
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Vérifier l'état de l'authentification
      print('🔍 Vérification de l\'état d\'authentification...');
      print('📱 Firebase Auth instance: ${_auth.toString()}');

      // Attendre un peu pour s'assurer que l'état est stable
      await Future.delayed(const Duration(milliseconds: 500));

      final user = _auth.currentUser;
      print('👤 Utilisateur actuel: ${user?.uid ?? 'NULL'}');
      print('📞 Numéro de téléphone: ${user?.phoneNumber ?? 'NULL'}');
      print('📧 Email: ${user?.email ?? 'NULL'}');

      if (user == null) {
        // Essayer de récupérer l'utilisateur depuis le stockage local
        print('⚠️ Utilisateur null, tentative de récupération...');

        final userDetailsJson = LocalStorageFactory().getUserDetails();
        if (userDetailsJson != null && userDetailsJson.isNotEmpty) {
          try {
            final userDetails = userDetailsJson is String
                ? jsonDecode(userDetailsJson)
                : userDetailsJson;
            final storedPhoneNumber = userDetails['phoneNumber']?.toString();

            if (storedPhoneNumber != null && storedPhoneNumber.isNotEmpty) {
              print('📱 Numéro stocké localement: $storedPhoneNumber');

              // Fermer l'indicateur de chargement
              navigator.pop();

              // Tenter la suppression directe avec le numéro stocké
              await _deleteAccountByPhoneNumber(
                  storedPhoneNumber, navigator, messenger);
              return;
            }
          } catch (e) {
            print('❌ Erreur lecture stockage local: $e');
          }
        }

        // Fermer l'indicateur de chargement
        navigator.pop();

        // Afficher le message avec le contexte sauvegardé
        messenger.showSnackBar(
          const SnackBar(
            content: Text(ErrorMessages.sessionExpired),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Récupérer le numéro de téléphone de l'utilisateur connecté
      final phoneNumber = user.phoneNumber;
      if (phoneNumber == null || phoneNumber.isEmpty) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ErrorMessages.phoneNumberNotFound),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Supprimer le compte Firebase Auth EN PREMIER
      print('🔥 Suppression du compte Firebase Auth...');
      print('👤 Utilisateur à supprimer:');
      print('  - UID: ${user.uid}');
      print('  - Phone: ${user.phoneNumber}');
      print('  - Email: ${user.email}');
      print('  - Email vérifié: ${user.emailVerified}');
      print('  - Créé le: ${user.metadata.creationTime}');
      print('  - Dernière connexion: ${user.metadata.lastSignInTime}');

      try {
        await user.delete();
        print('✅ Compte Firebase Auth supprimé avec succès');

        // Vérifier que l'utilisateur est bien supprimé
        final userAfterDelete = _auth.currentUser;
        if (userAfterDelete == null) {
          print('✅ Vérification: Utilisateur bien supprimé de Firebase Auth');
        } else {
          print(
              '⚠️ ATTENTION: Utilisateur toujours présent après suppression: ${userAfterDelete.uid}');
        }
      } catch (e) {
        print('❌ Erreur suppression Firebase Auth: $e');
        print('❌ Type d\'erreur: ${e.runtimeType}');

        if (e.toString().contains('requires-recent-login')) {
          print('⚠️ Ré-authentification requise pour Firebase Auth');
          // Fermer l'indicateur de chargement
          navigator.pop();
          // Afficher message et rediriger
          messenger.showSnackBar(
            const SnackBar(
              content: Text(ErrorMessages.reauthenticationRequired),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          // Rediriger vers auth_page
          singleton<AppRouter>().replace(const AuthRoute());
          return;
        } else {
          // Autre erreur Firebase Auth
          print('❌ Erreur inattendue Firebase Auth: $e');
          throw e;
        }
      }

      // Supprimer le token FCM
      print('🗑️ Suppression du token FCM...');
      try {
        await FCMService().removeCurrentToken();
        print('✅ Token FCM supprimé');
      } catch (e) {
        print('⚠️ Erreur suppression token FCM: $e');
      }

      // Supprimer les données Firestore APRÈS la suppression Firebase Auth
      print('🗑️ Suppression des données Firestore...');
      await _deleteUserData(phoneNumber);

      // Nettoyer le stockage local
      print('🧹 Nettoyage du stockage local...');
      await _clearLocalData();

      // Fermer l'indicateur de chargement
      navigator.pop();

      // Afficher un message de succès
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Compte supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Rediriger vers la page de connexion
      singleton<AppRouter>().replace(const AuthRoute());
    } catch (e) {
      // Fermer l'indicateur de chargement
      navigator.pop();

      // Afficher l'erreur
      messenger.showSnackBar(
        const SnackBar(
          content: Text(ErrorMessages.accountDeletionFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Supprimer les données utilisateur de Firestore
  static Future<void> _deleteUserData(String phoneNumber) async {
    try {
      // Supprimer le document utilisateur en utilisant le numéro de téléphone
      await _firestore.collection('users').doc(phoneNumber).delete();

      // Supprimer les commandes associées (optionnel)
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

      // Supprimer les autres données associées si nécessaire
      // Par exemple, les notifications, les préférences, etc.
    } catch (e) {
      print('Erreur lors de la suppression des données Firestore: $e');
      // On continue même si la suppression des données échoue
    }
  }

  /// Nettoyer toutes les données locales
  static Future<void> _clearLocalData() async {
    try {
      // Récupérer le numéro de téléphone avant de tout effacer
      final user = _auth.currentUser;
      final phoneNumber = user?.phoneNumber;

      // Nettoyer SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Si on a un numéro, le remettre dans SharedPreferences
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await prefs.setString('last_phone_number', phoneNumber);
        print(
            '📱 Numéro de téléphone sauvegardé pour la prochaine connexion: $phoneNumber');
      }

      // Nettoyer le stockage local personnalisé
      final localStorage = LocalStorageFactory();
      await localStorage.clearUserDetails();
    } catch (e) {
      print('Erreur lors du nettoyage des données locales: $e');
    }
  }

  /// Supprimer le compte directement par numéro de téléphone
  static Future<void> _deleteAccountByPhoneNumber(
    String phoneNumber,
    NavigatorState navigator,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      print('🗑️ Suppression directe du compte $phoneNumber...');

      // Afficher un message d'information
      messenger.showSnackBar(
        SnackBar(
          content: Text('🗑️ Suppression du compte $phoneNumber en cours...'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      // Essayer de supprimer le compte Firebase Auth d'abord
      try {
        final user = _auth.currentUser;
        if (user != null && user.phoneNumber == phoneNumber) {
          print('🔥 Suppression du compte Firebase Auth...');
          await user.delete();
          print('✅ Compte Firebase Auth supprimé avec succès');
        } else {
          print(
              '⚠️ Utilisateur Firebase Auth non connecté ou numéro différent');
        }
      } catch (e) {
        print('⚠️ Erreur suppression Firebase Auth: $e');
        if (e.toString().contains('requires-recent-login')) {
          print('⚠️ Ré-authentification requise pour Firebase Auth');
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Ré-authentification requise. Veuillez vous reconnecter pour supprimer le compte.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          // Rediriger vers auth_page
          singleton<AppRouter>().replace(const AuthRoute());
          return;
        }
        // Pour les autres erreurs, on continue avec la suppression Firestore
      }

      // Supprimer le token FCM
      print('🗑️ Suppression du token FCM...');
      try {
        await FCMService().removeCurrentToken();
        print('✅ Token FCM supprimé');
      } catch (e) {
        print('⚠️ Erreur suppression token FCM: $e');
      }

      // Supprimer les données Firestore
      print('📱 Suppression des données Firestore...');
      await _deleteUserData(phoneNumber);

      // Nettoyer le stockage local
      print('🧹 Nettoyage du stockage local...');
      await _clearLocalData();

      // Afficher le message de succès
      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ Compte $phoneNumber supprimé avec succès!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      // Rediriger vers la page de connexion
      print('🔄 Redirection vers la page de connexion...');
      await Future.delayed(const Duration(seconds: 2));
      singleton<AppRouter>().replace(const AuthRoute());
    } catch (e) {
      print('❌ Erreur lors de la suppression directe: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  /// Méthode de test pour forcer la suppression Firebase Auth
  static Future<void> testFirebaseAuthDeletion() async {
    try {
      print('🧪 === TEST SUPPRESSION FIREBASE AUTH ===');

      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Aucun utilisateur connecté pour le test');
        return;
      }

      print('👤 Utilisateur connecté:');
      print('  - UID: ${user.uid}');
      print('  - Phone: ${user.phoneNumber}');
      print('  - Email: ${user.email}');
      print('  - Créé le: ${user.metadata.creationTime}');
      print('  - Dernière connexion: ${user.metadata.lastSignInTime}');

      print('🔥 Tentative de suppression directe...');
      await user.delete();

      print('✅ Suppression réussie !');

      // Vérifier
      final userAfterDelete = _auth.currentUser;
      if (userAfterDelete == null) {
        print('✅ Vérification: Utilisateur bien supprimé');
      } else {
        print(
            '❌ PROBLÈME: Utilisateur toujours présent: ${userAfterDelete.uid}');
      }
    } catch (e) {
      print('❌ Erreur lors du test: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');

      if (e.toString().contains('requires-recent-login')) {
        print('⚠️ Ré-authentification requise');
      } else if (e.toString().contains('network')) {
        print('⚠️ Problème de réseau');
      } else {
        print('⚠️ Autre erreur: $e');
      }
    }

    print('🏁 === TEST TERMINÉ ===');
  }

  /// Méthode de test pour vérifier l'état d'authentification
  static Future<Map<String, dynamic>> checkAuthStatus() async {
    final Map<String, dynamic> status = {};

    try {
      // Vérifier Firebase Auth
      final user = _auth.currentUser;
      status['firebaseUser'] = user != null;
      status['uid'] = user?.uid;
      status['phoneNumber'] = user?.phoneNumber;
      status['email'] = user?.email;

      // Vérifier le stockage local
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      if (userDetailsJson != null && userDetailsJson.isNotEmpty) {
        try {
          final userDetails = userDetailsJson is String
              ? jsonDecode(userDetailsJson)
              : userDetailsJson;
          status['localStorage'] = true;
          status['localPhoneNumber'] = userDetails['phoneNumber'];
          status['localName'] = userDetails['name'];
        } catch (e) {
          status['localStorage'] = false;
          status['localError'] = e.toString();
        }
      } else {
        status['localStorage'] = false;
      }

      print('🔍 État d\'authentification: $status');
    } catch (e) {
      status['error'] = e.toString();
      print('❌ Erreur vérification état: $e');
    }

    return status;
  }
}
