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
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  Future<bool> checkUserExists(String phoneNumber) async {
    print('Checking user with phone: $phoneNumber');
    final response = await http.get(
      Uri.parse('http://api-restaurant.toptelsig.com/user/$phoneNumber'),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await singleton<LocalStorageFactory>().setUserDetails({
        "name": data["name"],
        "lastName": data["lastname"],
        "phoneNumber": data["phone_number"],
        "role" : data["role"],
      });
      return true;
    }
    return false;
  }

  Future<bool> submit(BuildContext context, WidgetRef ref) async {
    final phoneNumber = state.phoneNumber.trim();
    state = state.copyWith(
      hasError: false,
      errorText: '',
      status: AuthStatus.Processing,
    );
    ref.read(loadingProvider.notifier).start();

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
        errorText: 'Le numéro doit contenir exactement 10 chiffres',
        status: AuthStatus.Error,
      );
      ref.read(loadingProvider.notifier).complete();
      return false;
    }

    // Vérification MySQL
    final exists = await checkUserExists(phoneNumber);
    if (!exists) {
      state = state.copyWith(
        hasError: true,
        errorText: 'Ce numéro n\'existe pas dans notre base.',
        status: AuthStatus.Error,
      );
      ref.read(loadingProvider.notifier).complete();

    }

    try {
      if (exists) {
        ref.read(authProvider).login();

        ref.read(homeProvider.notifier).refreshUser();

        state = state.copyWith(status: AuthStatus.Success);
        clear();
        context.pushRoute(const ShareLocationRoute());
        return true;
      } else {
        await AuthService().verifynumpad(
          phoneNumber: phoneNumber,
          context: context,
          onCodeSent: (verificationId) {
            singleton<LocalStorageFactory>().setUserDetails({
              "phoneNumber": phoneNumber,
            });
            singleton<AppRouter>()
                .replace(OtpRoute(verificationId: verificationId));
          },
        );
        state = state.copyWith(status: AuthStatus.Success);
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorText: e.toString(),
        status: AuthStatus.Error,
      );
      return false;
    } finally {
      ref.read(loadingProvider.notifier).complete();
      state = state.copyWith(status: AuthStatus.Empty);
    }
  }

  void clear() {
    state = _initial;
  }
}

final loginProvider =
    StateNotifierProvider.autoDispose<LoginProvider, AuthModel>(
  (ref) => LoginProvider(),
);
