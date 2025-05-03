


import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/auth/auth_service.dart';

import '../../core/loading_provider.dart';
import '../../core/singletons.dart';
import '../../routes/app_router.dart';
import '../../routes/app_router.gr.dart';

enum OtpStatus {
  Empty,
  Processing,
  Error,
  Success,
  Dirty,
}

class OtpState {
  final bool hasError;
  final String errorMessage;
  final OtpStatus status;
  final String pin;

  OtpState({
    this.hasError = false,
    this.errorMessage = '',
    this.status = OtpStatus.Empty,
    this.pin = '',

  });

  OtpState copyWith({
    bool? hasError,
    String? errorMessage,
    OtpStatus? status,
    String? pin,
  }){
    return OtpState(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      pin: pin ?? this.pin,
    );
  }
}

class OtpNotifier extends StateNotifier<OtpState> {
  late final Ref ref;
  late final String verificationId;

  OtpNotifier(this.ref, this.verificationId) : super(OtpState());

  void updatePin(String pin) {
    state = state.copyWith(
      pin: pin,
      hasError: false,
      errorMessage: '',
      status: OtpStatus.Dirty,
    );
  }

  Future<void> verifyOTP(BuildContext context) async {
    final pin = state.pin.trim();
    print('Verifying OTP: $pin with verificationId: $verificationId');

    state = state.copyWith(
      hasError: false,
      errorMessage: '',
      status: OtpStatus.Processing,
      pin: '',
    );
    ref.read(loadingProvider.notifier).start();

    if (pin.length != 6) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Le code doit contenir 6 chiffres',
        status: OtpStatus.Error,
        pin: '',
      );
      ref.read(loadingProvider.notifier).complete();
      return;
    }

    try {
      await AuthService().verifOtp(
        otp: pin,
        verificationId: verificationId,
        onSuccess: () {
          state = state.copyWith(
            pin: '',
            hasError: false,
            errorMessage: '',
            status: OtpStatus.Success,
          );
          ref.read(loadingProvider.notifier).complete();
          singleton<AppRouter>().replace(const InfoUserRoute());
        },
        onError: (error) {
          state = state.copyWith(
            pin: '',
            hasError: true,
            errorMessage: error,
            status: OtpStatus.Error,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        pin: '',
        hasError: true,
        errorMessage: e.toString(),
        status: OtpStatus.Error,
      );
    } finally {
      ref.read(loadingProvider.notifier).complete();
      state = state.copyWith(status: OtpStatus.Empty, pin: '');
    }
  }
}

final otpProvider = StateNotifierProvider.family<OtpNotifier, OtpState, String>(
      (ref, verificationId) => OtpNotifier(ref, verificationId),
);
