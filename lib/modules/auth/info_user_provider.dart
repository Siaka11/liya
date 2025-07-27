import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart'; // Pour context.pushRoute
import 'package:liya/core/singletons.dart';
import 'package:liya/modules/auth/auth_service.dart'; // Votre AuthService
import 'package:liya/providers/loading_provider.dart'; // Votre LoadingProvider
import 'package:liya/routes/app_router.gr.dart';

import '../../core/local_storage_factory.dart';
import '../../routes/app_router.dart';
import '../home/application/home_provider.dart';
import 'firebase_auth_service.dart'; // Vos routes générées
// Importez votre AuthProvider si nécessaire, mais évitez d'appeler .login()

enum InfoUserStatus { Empty, Processing, Error, Success }

// Modèle d'état pour le formulaire d'informations utilisateur
class InfoUserState {
  final String name;
  final String lastName;
  final bool hasError;
  final String errorText;
  final InfoUserStatus status;

  const InfoUserState({
    this.name = '',
    this.lastName = '',
    this.hasError = false,
    this.errorText = '',
    this.status = InfoUserStatus.Empty,
  });

  InfoUserState copyWith({
    String? name,
    String? lastName,
    bool? hasError,
    String? errorText,
    InfoUserStatus? status,
  }) {
    return InfoUserState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      hasError: hasError ?? this.hasError,
      errorText: errorText ?? this.errorText,
      status: status ?? this.status,
    );
  }
}

// Provider de l'état de la page d'informations utilisateur
class InfoUserNotifier extends StateNotifier<InfoUserState> {
  final Ref ref; // Injection de Ref pour accéder aux autres providers

  InfoUserNotifier(this.ref) : super(const InfoUserState());

  // Met à jour le nom
  void updateName(String name) {
    state = state.copyWith(name: name, status: InfoUserStatus.Empty);
  }

  // Met à jour le prénom
  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName, status: InfoUserStatus.Empty);
  }

  /// Soumet les informations de l'utilisateur
  Future<void> submit(BuildContext context) async {
    final name = state.name.trim();
    final lastName = state.lastName.trim();

    print('Submitting user info: name=$name, lastName=$lastName');

    state = state.copyWith(
      hasError: false,
      errorText: '',
      status: InfoUserStatus.Processing,
    );
    ref
        .read(loadingProvider.notifier)
        .start(); // Affiche l'indicateur de chargement

    // Validations
    if (name.isEmpty || lastName.isEmpty) {
      print('Validation failed: Empty fields');
      state = state.copyWith(
        hasError: true,
        errorText: 'Veuillez remplir tous les champs.',
        status: InfoUserStatus.Error,
      );
      ref.read(loadingProvider.notifier).complete();
      return;
    }

    try {
      final authService =
          FirebaseAuthService(); // Obtenez l'instance du service
      final currentUser = authService.currentUser;

      if (currentUser == null || currentUser.phoneNumber == null) {
        throw Exception(
            'Utilisateur non connecté ou numéro de téléphone manquant.');
      }

      // Normaliser le numéro de téléphone pour correspondre au format des IDs de documents Firestore
      final firestorePhone =
          authService.normalizePhoneForFirestore(currentUser.phoneNumber!);
      print(
          '🔍 Utilisation du format Firestore pour la mise à jour: $firestorePhone');

      // Mettre à jour les informations dans Firestore
      await authService.updateUserInfo(
        firestorePhone,
        {
          'name': name,
          'lastname': lastName,
        },
      );

      state = state.copyWith(
        hasError: false,
        errorText: '',
        status: InfoUserStatus.Success,
      );

      // Mettre à jour les informations localement pour qu'elles soient disponibles immédiatement
      var userDetail = {"name": name, "lastName": lastName};
      singleton<LocalStorageFactory>().setUserDetails(userDetail);

      // SUPPRIMÉ : ref.read(authProvider).login();

      // Rafraîchir les données utilisateur dans HomeProvider si nécessaire
      ref.read(homeProvider.notifier).refreshUser();

      // Naviguer vers la page principale
      singleton<AppRouter>().replace(const ShareLocationRoute());
      print('User info saved successfully and navigated to ShareLocation.');
    } catch (e) {
      print('Error saving user info: $e');
      state = state.copyWith(
        hasError: true,
        errorText: e.toString().replaceFirst('Exception: ', ''),
        status: InfoUserStatus.Error,
      );
    } finally {
      ref
          .read(loadingProvider.notifier)
          .complete(); // Cache l'indicateur de chargement
    }
  }

  // Réinitialise l'état du formulaire
  void reset() {
    state = const InfoUserState();
  }
}

// Déclaration du provider d'informations utilisateur
final infoUserProvider = StateNotifierProvider<InfoUserNotifier, InfoUserState>(
  (ref) => InfoUserNotifier(ref), // Passe la référence à ref au constructeur
);
