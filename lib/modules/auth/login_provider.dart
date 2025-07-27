import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart'; // Pour la navigation AutoRouter
// import 'package:http/http.dart' as http; // Pour l'API MySQL
import 'package:liya/core/singletons.dart';
import 'package:liya/modules/auth/auth_provider.dart'; // Importez votre AuthProvider
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:liya/providers/loading_provider.dart'; // Pour afficher/cacher l'indicateur de chargement
import 'package:liya/routes/app_router.gr.dart';

import '../../core/local_storage_factory.dart';
import '../home/application/home_provider.dart'; // Vos routes générées par AutoRouter

// Enum pour l'état du formulaire
enum AuthStatus { Empty, Processing, Error, Success, Dirty }

// Modèle d'état pour le formulaire de connexion
class AuthModel {
  final String phoneNumber;
  final String otp;
  final String name;
  final String lastName;
  final String? verificationId;
  final AuthStatus status;
  final bool hasError;
  final String errorText;

  const AuthModel({
    this.phoneNumber = '',
    this.otp = '',
    this.name = '',
    this.lastName = '',
    this.verificationId,
    this.status = AuthStatus.Empty,
    this.hasError = false,
    this.errorText = '',
  });

  AuthModel copyWith({
    String? phoneNumber,
    String? otp,
    String? name,
    String? lastName,
    String? verificationId,
    AuthStatus? status,
    bool? hasError,
    String? errorText,
  }) {
    return AuthModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      verificationId: verificationId ?? this.verificationId,
      status: status ?? this.status,
      hasError: hasError ?? this.hasError,
      errorText: errorText ?? this.errorText,
    );
  }

  bool get isProcessing => status == AuthStatus.Processing;
}

// Provider de l'état de la page de connexion
class LoginProvider extends StateNotifier<AuthModel> {
  final Ref ref; // Injection de Ref pour accéder aux autres providers

  LoginProvider(this.ref) : super(_initial);

  static const _initial = AuthModel();

  // Met à jour le numéro de téléphone et l'état du formulaire
  void updatePhoneNumber(String value) {
    state = state.copyWith(
      phoneNumber: value,
      status: AuthStatus.Dirty, // Indique que le formulaire a été modifié
    );
  }

  /// Vérifie si l'utilisateur existe dans Firestore
  Future<bool> checkUserExists(String phoneNumber) async {
    print('Checking user with phone (Firestore): $phoneNumber');
    try {
      final authService = FirebaseAuthService();
      final firestorePhone =
          authService.normalizePhoneForFirestore(phoneNumber);
      final userInfo = await authService.getUserInfo(firestorePhone);

      if (userInfo != null) {
        // Stocke les détails de l'utilisateur récupérés de Firestore localement
        await singleton<LocalStorageFactory>().setUserDetails({
          "name": userInfo["name"] ?? "",
          "lastName": userInfo["lastname"] ?? "",
          "phoneNumber": userInfo["phoneNumber"] ?? phoneNumber,
          "role": userInfo["role"] ?? "client",
        });
        return true;
      }
    } catch (e) {
      print('Error checking user existence in Firestore: $e');
    }
    return false;
  }

  /// Soumet le numéro de téléphone pour la connexion/inscription
  Future<bool> submit(BuildContext context) async {
    final phoneNumber = state.phoneNumber.trim();
    state = state.copyWith(
      hasError: false,
      errorText: '',
      status: AuthStatus.Processing, // Passe à l'état de traitement
    );
    ref
        .read(loadingProvider.notifier)
        .start(); // Affiche l'indicateur de chargement

    // Validations côté client
    if (phoneNumber.isEmpty) {
      state = state.copyWith(
        hasError: true,
        errorText: 'Veuillez entrer un numéro de téléphone',
        status: AuthStatus.Error,
      );
      ref.read(loadingProvider.notifier).complete();
      return false;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      state = state.copyWith(
        hasError: true,
        errorText:
            'Le numéro doit contenir exactement 10 chiffres (ex: 0701234567)',
        status: AuthStatus.Error,
      );
      ref.read(loadingProvider.notifier).complete();
      return false;
    }

    try {
      final authNotifier = ref.read(authProvider.notifier);

      // Tente d'envoyer l'OTP (ou d'effectuer l'auto-vérification) via AuthProvider
      final otpWasNeeded = await authNotifier.sendOTP(phoneNumber);

      if (otpWasNeeded) {
        // L'OTP a été envoyé, nous devons naviguer vers la page de vérification OTP
        final verificationId =
            authNotifier.currentVerificationId; // <-- CORRECTION ICI
        if (verificationId != null) {
          // Sauvegarde le phoneNumber localement avant de naviguer vers la page OTP
          await singleton<LocalStorageFactory>().setUserDetails({
            "phoneNumber": phoneNumber,
          });
          context.router.replace(OtpRoute(verificationId: verificationId));
        } else {
          throw Exception(
              "L'ID de vérification est manquant après l'envoi de l'OTP.");
        }
      } else {
        // L'auto-vérification Firebase a réussi, l'utilisateur est maintenant connecté via Firebase.
        // Maintenant, vérifions l'existence de l'utilisateur dans Firestore pour décider de la navigation.
        final existsInFirestore = await checkUserExists(phoneNumber);

        if (existsInFirestore) {
          // Utilisateur existant dans Firestore et connecté via Firebase.
          ref
              .read(homeProvider.notifier)
              .refreshUser(); // Rafraîchir les infos utilisateur si nécessaire
          context.router.replace(
              const ShareLocationRoute()); // Naviguer vers la page principale
        } else {
          // Nouvel utilisateur (non trouvé dans Firestore) mais connecté via Firebase (auto-vérification).
          // Il doit compléter son profil.
          context.router.replace(const InfoUserRoute());
        }
      }
      state = state.copyWith(status: AuthStatus.Success);
      clear(); // Réinitialise l'état du formulaire
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        hasError: true,
        errorText: e.toString().replaceFirst(
            'Exception: ', ''), // Nettoie le préfixe "Exception: "
        status: AuthStatus.Error,
      );
      return false;
    } finally {
      ref
          .read(loadingProvider.notifier)
          .complete(); // Cache l'indicateur de chargement
      state = state.copyWith(
          status: AuthStatus.Empty); // Réinitialise l'état du formulaire
    }
  }

  // Réinitialise l'état du formulaire
  void clear() {
    state = _initial;
  }
}

// Déclaration du provider de connexion
final loginProvider =
    StateNotifierProvider.autoDispose<LoginProvider, AuthModel>(
  (ref) => LoginProvider(ref), // Passe la référence à ref au constructeur
);
