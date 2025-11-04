import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/core/constants/error_messages.dart';
import 'package:liya/core/providers/guest_mode_provider.dart';

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
  final Ref ref;

  OtpNotifier(this.verificationId, this.ref)
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
      print('🔍 Début vérification OTP avec pin: ${state.pin}');

      // Vérifier que le verificationId existe avant d'essayer
      final verificationId = await _authService.getVerificationId();
      if (verificationId == null) {
        throw Exception(ErrorMessages.missingVerificationId);
      }
      print('✅ VerificationId trouvé: ${verificationId.substring(0, 10)}...');

      final userCredential = await _authService.verifyOTP(state.pin);
      print('✅ OTP vérifié avec succès');

      if (userCredential.user != null) {
        state = state.copyWith(isVerified: true, isLoading: false);
        
        // Désactiver le mode invité lors d'une connexion réussie
        await ref.read(guestModeProvider.notifier).disableGuestMode();
        print('✅ Mode invité désactivé après vérification OTP');

        // Navigation vers la page d'informations utilisateur
        if (context.mounted) {
          print('🔄 Redirection vers InfoUserRoute');
          // Forcer la redirection vers InfoUserRoute en remplaçant la stack
          context.router.replace(const InfoUserRoute());
        }
      }
    } catch (e) {
      print('❌ Erreur vérification OTP: $e');

      // Utiliser des messages d'erreur professionnels
      String errorMessage = ErrorMessages.otpVerificationFailed;

      // Si c'est une exception avec un message personnalisé, l'utiliser
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        final message = e.toString().substring(11); // Enlever "Exception: "
        if (message.startsWith('🔢') ||
            message.startsWith('⏰') ||
            message.startsWith('🔍') ||
            message.startsWith('🛡️')) {
          errorMessage = message;
        }
      }

      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> resendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: '');

    try {
      await _authService.sendOTP(phoneNumber);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = ErrorMessages.otpResendFailed;

      // Messages d'erreur plus spécifiques et professionnels
      if (e.toString().contains('too-many-requests')) {
        errorMessage = ErrorMessages.otpTooManyAttempts;
      } else if (e.toString().contains('invalid-phone-number')) {
        errorMessage = ErrorMessages.invalidPhoneNumber;
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = ErrorMessages.quotaExceeded;
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = ErrorMessages.networkRequestFailed;
      } else if (e.toString().contains('app-not-authorized')) {
        errorMessage = ErrorMessages.appNotAuthorized;
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
  (ref, verificationId) => OtpNotifier(verificationId, ref),
);
