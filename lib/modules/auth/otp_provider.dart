


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
  Success
}

class OtpState {
  final bool hasError;
  final String errorMessage;
  final OtpStatus status;

  OtpState({
    this.hasError = false,
    this.errorMessage = '',
    this.status = OtpStatus.Empty,
  });

  OtpState copyWith({
    bool? hasError,
    String? errorMessage,
    OtpStatus? status,
  }){
    return OtpState(
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}

class OtpNotifier extends StateNotifier<OtpState> {
  late final Ref ref;
  late final String verificationId;
  final TextEditingController pinController = TextEditingController();

  OtpNotifier(this.ref, this.verificationId) : super(OtpState());

  Future<void> verifyOTP(BuildContext context) async {
    final pin = pinController.text.trim();
    print('Verifying OTP: $pin with verificationId: $verificationId');
    state = state.copyWith(
      hasError: false,
      errorMessage: '',
      status: OtpStatus.Processing,
    );
    ref.read(loadingProvider.notifier).start();

    if (pin.length != 6) {
      state = state.copyWith(
        hasError: true,
        errorMessage: 'Le code doit contenir 6 chiffres',
        status: OtpStatus.Error,
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
            hasError: false,
            errorMessage: '',
            status: OtpStatus.Success,
          );
          ref.read(loadingProvider.notifier).complete();
          singleton<AppRouter>().replace(const InfoUserRoute());
        },
        onError: (error) {
          state = state.copyWith(
            hasError: true,
            errorMessage: error,
            status: OtpStatus.Error,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        errorMessage: e.toString(),
        status: OtpStatus.Error,
      );
    } finally {
      ref.read(loadingProvider.notifier).complete();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pinController.dispose();
  }
}

final otpProvider = StateNotifierProvider.family<OtpNotifier, OtpState, String>(
      (ref, verificationId) => OtpNotifier(ref, verificationId),
);
