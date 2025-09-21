import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/auth/otp_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:liya/core/ui/components/custom_button.dart';
import 'package:liya/core/services/connection_manager.dart';
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
          child: otpState.isLoading
              ? _buildLoadingWidget()
              : _buildOTPWidget(otpNotifier, otpState),
        ),
      ),
    );
  }

  /// Widget de chargement bien visible
  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 40),

        // Spinner principal bien visible
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinner principal
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(UIColors.orange),
                ),
              ),
              const SizedBox(height: 20),

              // Message de chargement
              const Text(
                'Vérification en cours...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UIColors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez patienter pendant que nous vérifions votre code',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Message du numéro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Code envoyé au ${widget.phoneNumber}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Widget principal de saisie OTP
  Widget _buildOTPWidget(OtpNotifier otpNotifier, OtpState otpState) {
    return Column(
      children: [
        // Logo
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

        // Titre et description
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

        // Champ de saisie OTP
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Pinput(
                length: 6,
                autofocus: true,
                controller: _pinController,
                onCompleted: (pin) {
                  otpNotifier.updatePin(pin);
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

        // Message d'erreur
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

        // Bouton renvoyer SMS
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 120,
              height: 30,
              child: CustomButton(
                text: _canResend ? 'Renvoyer SMS' : '${_resendCountdown}s',
                onPressedButton: _canResend ? _resendOTP : null,
                bgColor: _canResend ? UIColors.white : Colors.white,
                fontSize: 10,
                paddingVertical: 8,
                borderRadius: 16,
                width: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
