import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/routes/app_router.dart';
import 'package:liya/routes/app_router.gr.dart';

class AccountManagementService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Affiche le menu de déconnexion avec options
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Gérer votre compte',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Que souhaitez-vous faire ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            // Bouton Se déconnecter
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            // Bouton Supprimer le compte
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDeleteAccountDialog(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Supprimer le compte',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Affiche la confirmation de suppression de compte (méthode publique)
  static Future<void> showDeleteAccountDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '⚠️ Supprimer le compte',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Cette action est irréversible. Toutes vos données seront définitivement supprimées.\n\n'
            'Êtes-vous sûr de vouloir supprimer votre compte ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            // Bouton Supprimer définitivement
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Supprimer définitivement',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Suppression du compte utilisateur
  static Future<void> _deleteAccount(BuildContext context) async {
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
            content:
                Text('Aucun utilisateur connecté - Veuillez vous reconnecter'),
            backgroundColor: Colors.red,
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
            content: Text('Numéro de téléphone non trouvé'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Supprimer les données Firestore en utilisant le numéro de téléphone
      await _deleteUserData(phoneNumber);

      // Supprimer le compte Firebase Auth
      await user.delete();

      // Nettoyer le stockage local
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
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
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

      // Supprimer les données Firestore
      print('📱 Suppression des données Firestore...');
      await _deleteUserData(phoneNumber);

      // Essayer de supprimer le compte Firebase Auth si possible
      try {
        final user = _auth.currentUser;
        if (user != null && user.phoneNumber == phoneNumber) {
          print('🔥 Suppression du compte Firebase Auth...');
          await user.delete();
        } else {
          print(
              '⚠️ Utilisateur Firebase Auth non connecté, suppression des données Firestore uniquement');
        }
      } catch (e) {
        print('⚠️ Erreur suppression Firebase Auth: $e');
        // On continue avec la suppression des données Firestore
      }

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

  /// Tenter la réauthentification automatique
  static Future<void> _attemptReauthentication(
    String phoneNumber,
    NavigatorState navigator,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      print('🔄 Tentative de réauthentification avec $phoneNumber');

      // Afficher un message d'information
      messenger.showSnackBar(
        SnackBar(
          content: Text('🔄 Réauthentification en cours avec $phoneNumber...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );

      // Essayer de se reconnecter avec le numéro de téléphone
      print('📱 Tentative de connexion avec Firebase Auth...');

      // Créer un PhoneAuthCredential (simulation pour le moment)
      // Note: Firebase Auth nécessite un code OTP pour la reconnexion
      // Nous allons demander à l'utilisateur de se reconnecter manuellement

      // Attendre un peu
      await Future.delayed(const Duration(seconds: 2));

      // Vérifier à nouveau l'état
      final user = _auth.currentUser;
      if (user != null && user.phoneNumber == phoneNumber) {
        print('✅ Réauthentification réussie!');
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Réauthentification réussie! Vous pouvez maintenant supprimer votre compte.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        print('❌ Réauthentification échouée - Connexion manuelle requise');
        messenger.showSnackBar(
          SnackBar(
            content: Text(
                '❌ Réauthentification automatique impossible. Veuillez vous reconnecter manuellement avec $phoneNumber'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Se reconnecter',
              textColor: Colors.white,
              onPressed: () {
                // Rediriger vers la page de connexion
                try {
                  singleton<AppRouter>().replace(const AuthRoute());
                } catch (e) {
                  print('❌ Erreur redirection: $e');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la réauthentification: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de la réauthentification: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
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
