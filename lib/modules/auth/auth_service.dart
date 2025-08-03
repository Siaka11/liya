import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liya/core/singletons.dart';

import '../../core/local_storage_factory.dart';
import '../../utils/snackbar.dart';
import 'firebase_auth_service.dart';

// Fonction utilitaire pour les SnackBar (assurez-vous qu'elle est définie quelque part, par exemple dans core/ui/components/snack_bar_utils.dart)
void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    ),
  );
}

class AuthService {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cette méthode est un wrapper direct pour FirebaseAuthService.sendOTP.
  // Idéalement, les appels devraient aller directement à AuthProvider.sendOTP.
  Future<void> verifynumpad({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required BuildContext context,
  }) async {
    try {
      // Appelle le sendOTP du service FirebaseAuthService
      final needsOTP = await _firebaseAuthService.sendOTP(phoneNumber);

      if (needsOTP) {
        final verificationId = await _firebaseAuthService.getVerificationId();
        if (verificationId != null) {
          onCodeSent(verificationId);
          showSnackBar(context, "Code envoyé");
        } else {
          throw Exception(
              "L'ID de vérification est manquant après l'envoi de l'OTP.");
        }
      } else {
        onCodeSent('auto_verified');
        showSnackBar(context, "Connexion auto-vérifiée !");
      }
    } catch (e) {
      showSnackBar(context, "Erreur d'envoi du code : ${e.toString()}",
          isError: true);
    }
  }

  // Cette méthode est un wrapper direct pour FirebaseAuthService.verifyOTP.
  // Idéalement, les appels devraient aller directement à AuthProvider.verifyOTP.
  Future<void> verifOtp({
    required String otp,
    required String
        verificationId, // Ce paramètre n'est plus utilisé par le service
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final userCredential = await _firebaseAuthService.verifyOTP(otp);
      if (userCredential.user != null) {
        onSuccess();
      } else {
        throw Exception("Échec de la vérification");
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // Cette méthode est un wrapper direct pour FirebaseAuthService.updateUserInfo.
  Future<void> saveUserInfo({
    required String name,
    required String lastName,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final currentUser = _firebaseAuthService.currentUser;
      if (currentUser?.phoneNumber == null) {
        throw Exception("Utilisateur non connecté");
      }

      // Normaliser le numéro de téléphone pour correspondre au format des IDs de documents Firestore
      final firestorePhone = _firebaseAuthService
          .normalizePhoneForFirestore(currentUser!.phoneNumber!);
      print(
          '🔍 Utilisation du format Firestore pour la sauvegarde des infos: $firestorePhone');

      await _firebaseAuthService.updateUserInfo(
        firestorePhone,
        {
          'name': name,
          'lastname': lastName,
        },
      );

      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

  // Cette méthode est un wrapper pour la mise à jour de la localisation.
  // Si la logique de localisation est simple, elle peut rester ici ou être déplacée dans un service dédié.
  Future<void> saveUserLocation({
    required double latitude,
    required double longitude,
    String? address,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final currentUser = _firebaseAuthService.currentUser;
      if (currentUser?.phoneNumber == null) {
        throw Exception("Utilisateur non connecté");
      }

      // Normaliser le numéro de téléphone pour correspondre au format des IDs de documents Firestore
      final firestorePhone = _firebaseAuthService
          .normalizePhoneForFirestore(currentUser!.phoneNumber!);
      print(
          '🔍 Utilisation du format Firestore pour la sauvegarde de localisation: $firestorePhone');

      final updateData = {
        'current_latitude': latitude,
        'current_longitude': longitude,
        'last_location_update': FieldValue.serverTimestamp(),
      };

      if (address != null && address.isNotEmpty) {
        updateData['delivery_address'] = address;
      }

      await _firestore
          .collection('users')
          .doc(firestorePhone)
          .update(updateData);

      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

// La méthode _formatPhoneNumber est une DUPLICATION et DOIT ÊTRE SUPPRIMÉE de ce fichier.
// Elle est déjà et doit rester uniquement dans FirebaseAuthService.
/*
  String _formatPhoneNumber(String phoneNumber) {
    // ... votre implémentation
  }
  */
}
