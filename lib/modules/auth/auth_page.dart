
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liya/core/ui/components/custom_button.dart';
import 'package:liya/core/ui/components/custom_field.dart';
import 'package:liya/modules/auth/login_provider.dart';

import '../../core/ui/theme/theme.dart';
import '../../routes/app_router.gr.dart';


@RoutePage()
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late final TextEditingController _phoneController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController();
    _phoneController.addListener(() {
      ref.read(loginProvider.notifier).updatePhoneNumber(_phoneController.text);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _animation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final loginForm = ref.read(loginProvider.notifier);
      final success = await loginForm.submit();
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code envoyé'),
            backgroundColor: Colors.green,
          ),
        );
        // Utiliser ref.read pour obtenir l'état le plus récent
        final updatedLoginState = ref.read(loginProvider);
        final verificationId = updatedLoginState.verificationId;
        if (mounted && verificationId != null) {
          context.router.replace(OtpRoute(verificationId: verificationId));
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur : verificationId manquant'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final loginForm = ref.read(loginProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.deepOrange.shade900],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value * 300 - 60),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/img/basilique.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  height: 180.0,
                  width: 180.0,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 200, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "VEUILLEZ SAISIR VOTRE NUMERO S'IL VOUS PLAÎT",
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ce numéro recevra un code de confirmation",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: CustomField(
                    controller: _phoneController,
                    fontSize: 21,
                    prefixText: "+225 ",
                    paddingLeft: 12,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 20),
                if (loginState.hasError)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      loginState.errorText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isSubmitting ? "Envoi en cours..." : "Envoyer",
                  borderRadius: 50,
                  onPressedButton: _isSubmitting ? null : _handleSubmit,
                  bgColor: UIColors.white,
                  fontSize: 18,
                  paddingVertical: 18,
                  width: 120,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


