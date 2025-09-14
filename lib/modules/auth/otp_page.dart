import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/auth/otp_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:liya/core/ui/components/custom_button.dart';
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:liya/core/test_otp_debug.dart';
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';
import 'package:liya/core/test_verification_id_debug.dart';
import 'dart:async';

@RoutePage()
class OtpPage extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber; // Ajout du numéro de téléphone

  const OtpPage(this.verificationId, {required this.phoneNumber, super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  late final TextEditingController _pinController;
  Timer? _resendTimer;
  int _resendCountdown = 60; // 60 secondes d'attente
  bool _canResend = false;

  // Gestionnaire de connexion
  final ConnectionManager _connectionManager = ConnectionManager();

  @override
  void initState() {
    super.initState();

    _pinController = TextEditingController();
    _pinController.addListener(() {
      ref
          .read(otpProvider(widget.verificationId).notifier)
          .updatePin(_pinController.text);
    });

    // Démarrer le timer pour le renvoi
    _startResendTimer();

    // Définir le contexte pour le gestionnaire de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _resendTimer?.cancel();
    _connectionManager.clearCurrentContext();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    final otpNotifier = ref.read(otpProvider(widget.verificationId).notifier);

    try {
      await otpNotifier.resendOTP(widget.phoneNumber);

      // Redémarrer le timer après un renvoi réussi
      _startResendTimer();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code OTP renvoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du renvoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider(widget.verificationId));
    final otpNotifier = ref.read(otpProvider(widget.verificationId).notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: UIColors.defaultColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Veuillez saisir le code envoyé",
                      style: TextStyle(
                        fontSize: 16,
                        color: UIColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Nous vous avons envoyé un code de confirmation à votre numéro de téléphone",
                      style: TextStyle(
                        fontSize: 12,
                        color: UIColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Pinput(
                      length: 6,
                      autofocus: true,
                      controller: _pinController,
                      onCompleted: (pin) {
                        otpNotifier.updatePin(pin); // On met à jour le provider
                        otpNotifier.verifyOTP(context);
                      },
                      defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: UIColors.black,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: UIColors.defaultColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: UIColors.black,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: UIColors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (otpState.hasError && otpState.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    otpState.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 120,
                    height: 30,
                    child: otpState.isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : CustomButton(
                            text: _canResend
                                ? 'Renvoyer SMS'
                                : '${_resendCountdown}s',
                            onPressedButton: _canResend ? _resendOTP : null,
                            bgColor: _canResend ? UIColors.orange : Colors.grey,
                            fontSize: 10,
                            paddingVertical: 8,
                            borderRadius: 16,
                            width: 50),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
