import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/modules/auth/auth_service.dart';
import 'package:liya/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_information.dart';
import '../../core/loading_provider.dart';
import '../../routes/app_router.gr.dart';
import '../home/application/home_provider.dart';
import 'auth_provider.dart';

enum AuthStatus { Empty, Dirty, Processing, Error, Success }

class AuthModel {
  final String phoneNumber;
  final String otp;
  final String name;
  final String lastName;
  final String? verificationId; // Nouveau champ pour stocker le verificationId
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

class LoginProvider extends StateNotifier<AuthModel> {
  LoginProvider() : super(_initial);

  static const _initial = AuthModel();

  void updatePhoneNumber(String value) {
    state = state.copyWith(
      phoneNumber: value,
      status: AuthStatus.Dirty,
    );
  }

  Future<bool> submit() async {
    final phoneNumber = state.phoneNumber.trim();

    if (phoneNumber.isEmpty) {
      state = state.copyWith(
        hasError: true,
        errorText: 'Veuillez entrer un numéro de téléphone',
        status: AuthStatus.Error,
      );
      return false;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      state = state.copyWith(
        hasError: true,
        errorText: 'Le numéro doit contenir exactement 10 chiffres',
        status: AuthStatus.Error,
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.Processing,
      hasError: false,
      errorText: '',
    );

    try {
      // Simulation de l'envoi d'un OTP (remplace par une vraie requête si nécessaire)
      //await Future.delayed(const Duration(seconds: 2));
      const verificationId = '123456'; // Simulé
      state = state.copyWith(
        verificationId: verificationId,
        status: AuthStatus.Success,
      );

      // Afficher une snackbar pour indiquer que le code a été envoyé

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.Error,
        hasError: true,
        errorText: 'Une erreur est survenue : $e',
      );
      return false;
    }
  }

  void clear() {
    state = _initial;
  }
}
/*
Future<void> submit(BuildContext context, WidgetRef ref) async {
  final cleanedPhone = state.phoneNumber.trim();

  state = state.copyWith(
    hasError: false,
    errorText: '',
    status: AuthStatus.Processing,
  );
  ref.read(loadingProvider.notifier).start();

  if (cleanedPhone.isEmpty || cleanedPhone.length < 10) {
    state = state.copyWith(
      hasError: true,
      errorText: 'Veuillez entrer un numéro de téléphone valide.',
      status: AuthStatus.Error,
    );
    ref.read(loadingProvider.notifier).complete();
    return;
  }

  try {
    if (cleanedPhone == '0709976498') {
      ref.read(authProvider).login();

      await singleton<LocalStorageFactory>().setUserDetails({
        "name": "auro2",
        "lastName": "Junior",
      });

      ref.read(homeProvider.notifier).refreshUser();

      state = state.copyWith(status: AuthStatus.Success);
      clear();
      context.pushRoute(const ShareLocationRoute());
    } else {
      await AuthService().verifynumpad(
        phoneNumber: cleanedPhone,
        context: context,
        onCodeSent: (verificationId) {
          singleton<AppRouter>().replace(OtpRoute(verificationId: verificationId));
        },
      );
      state = state.copyWith(status: AuthStatus.Success);
    }
  } catch (e) {
    state = state.copyWith(
      hasError: true,
      errorText: e.toString(),
      status: AuthStatus.Error,
    );
  } finally {
    ref.read(loadingProvider.notifier).complete();
    state = state.copyWith(status: AuthStatus.Empty);
  }
}*/
final loginProvider = StateNotifierProvider.autoDispose<LoginProvider, AuthModel>(
      (ref) => LoginProvider(),
);