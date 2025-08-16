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
                _showDeleteAccountConfirmation(context);
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

  /// Affiche la confirmation de suppression de compte
  static Future<void> _showDeleteAccountConfirmation(
      BuildContext context) async {
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

      final user = _auth.currentUser;
      if (user == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun utilisateur connecté'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Supprimer les données Firestore
      await _deleteUserData(user.uid);

      // Supprimer le compte Firebase Auth
      await user.delete();

      // Nettoyer le stockage local
      await _clearLocalData();

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte supprimé avec succès'),
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
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Supprimer les données utilisateur de Firestore
  static Future<void> _deleteUserData(String userId) async {
    try {
      // Supprimer le document utilisateur
      await _firestore.collection('users').doc(userId).delete();

      // Supprimer les commandes associées (optionnel)
      final ordersQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in ordersQuery.docs) {
        await doc.reference.delete();
      }

      // Supprimer les favoris associés (optionnel)
      final favoritesQuery = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in favoritesQuery.docs) {
        await doc.reference.delete();
      }
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
}
