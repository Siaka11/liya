import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// État OTP
class OtpState {
  final String pin;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool isVerified;

  OtpState({
    this.pin = '',
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.isVerified = false,
  });

  OtpState copyWith({
    String? pin,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isVerified,
  }) {
    return OtpState(
      pin: pin ?? this.pin,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

// Notifier OTP
class OtpNotifier extends StateNotifier<OtpState> {
  final String verificationId;
  final FirebaseAuthService _authService;

  OtpNotifier(this.verificationId)
      : _authService = FirebaseAuthService(),
        super(OtpState());

  void updatePin(String pin) {
    state = state.copyWith(pin: pin);
  }

  Future<void> verifyOTP(BuildContext context) async {
    if (state.pin.length != 6) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Veuillez saisir les 6 chiffres du code',
      );
      return;
    }

    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

    try {
      final userCredential = await _authService.verifyOTP(state.pin);

      if (userCredential.user != null) {
        state = state.copyWith(isVerified: true, isLoading: false);

        // Navigation vers la page d'informations utilisateur
        if (context.mounted) {
          context.router.push(const InfoUserRoute());
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Code incorrect: ${e.toString()}',
      );
    }
  }

  Future<void> resendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

    try {
      await _authService.sendOTP(phoneNumber);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = 'Erreur lors du renvoi';

      // Messages d'erreur plus spécifiques
      if (e.toString().contains('too-many-requests')) {
        errorMessage =
            'Trop de demandes. Attendez quelques minutes avant de réessayer.';
      } else if (e.toString().contains('invalid-phone-number')) {
        errorMessage = 'Numéro de téléphone invalide.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'Limite de SMS dépassée. Réessayez plus tard.';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Erreur réseau. Vérifiez votre connexion internet.';
      } else {
        errorMessage = 'Erreur lors du renvoi: ${e.toString()}';
      }

      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: errorMessage,
      );
    }
  }
}

// Provider OTP
final otpProvider = StateNotifierProvider.family<OtpNotifier, OtpState, String>(
  (ref, verificationId) => OtpNotifier(verificationId),
);
