import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart'; // Pour la navigation
import 'package:liya/modules/auth/auth_provider.dart'; // Votre AuthProvider
import 'package:liya/core/ui/components/custom_button.dart'; // Vos composants UI
import 'package:liya/core/ui/components/custom_field.dart'; // Vos composants UI
import 'package:liya/routes/app_router.gr.dart'; // Vos routes générées
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';

import '../../core/ui/theme/theme.dart'; // Votre thème UI
import '../home/application/home_provider.dart'; // Votre HomeProvider

@RoutePage() // Assurez-vous que cette annotation est présente si vous utilisez AutoRouter
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late final TextEditingController _phoneController;
  bool _isSubmitting = false;
  bool _hasShownLengthError = false; // Pour éviter les SnackBar répétés

  // Gestionnaire de connexion
  final ConnectionManager _connectionManager = ConnectionManager();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(() {
      _validatePhoneNumberLength();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _animation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Vérifier si l'utilisateur est déjà connecté
    _checkIfUserAlreadyAuthenticated();

    // Définir le contexte pour le gestionnaire de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
  }

  /// Vérifier si l'utilisateur est déjà authentifié
  Future<void> _checkIfUserAlreadyAuthenticated() async {
    try {
      final isAuthenticated =
          await ref.read(authProvider.notifier).checkAuthStateAndSync();

      if (isAuthenticated && mounted) {
        print(
            '✅ Utilisateur déjà authentifié, redirection vers share-location');
        // Rediriger directement vers la page de localisation
        context.router.pushNamed('/share-location');
      }
    } catch (e) {
      print('❌ Erreur vérification authentification: $e');
    }
  }

  void _validatePhoneNumberLength() {
    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (phoneNumber.isNotEmpty &&
        phoneNumber.length < 10 &&
        !_hasShownLengthError) {
      _hasShownLengthError = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Numéro incomplet. Vous avez saisi ${phoneNumber.length} chiffres sur 10 requis.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (phoneNumber.length >= 10) {
      _hasShownLengthError =
          false; // Reset pour permettre un nouveau message si nécessaire
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Protection contre les appels multiples
    if (_isSubmitting) {
      print('🛡️ Appel multiple bloqué');
      return;
    }

    // Extraire uniquement les chiffres
    final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    // Vérifier que le numéro a exactement 10 chiffres pour la Côte d'Ivoire
    if (phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Numéro invalide. Vous avez saisi ${phoneNumber.length} chiffres sur 10 requis. Format attendu: 0701234567'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Vérifier que le numéro commence par 0
    /* if (!phoneNumber.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Numéro invalide. Doit commencer par 0. Format: 0701234567'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }*/

    setState(() => _isSubmitting = true);

    // Préparer les données d'authentification
    final authData = {
      'phone': _phoneController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Sauvegarder les données localement
      await _connectionManager.saveRegistrationData(authData);

      // Exécuter l'authentification avec gestion de connexion
      final needsOTP = await _connectionManager.executeWithConnectionHandling(
        () => ref.read(authProvider.notifier).sendOTP(_phoneController.text),
        operationType: 'phone_authentication',
        fallbackData: authData,
      );

      if (mounted) {
        if (needsOTP) {
          // Cas 1 : OTP nécessaire (nouvel utilisateur ou utilisateur existant mais infos incomplètes)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code envoyé avec succès !'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Récupérer le verificationId et naviguer vers la page OTP
          final verificationId =
              await ref.read(authProvider.notifier).getVerificationId();
          if (verificationId != null && mounted) {
            context.router.push(OtpRoute(
              verificationId: verificationId,
              phoneNumber: _phoneController.text.trim(),
            ));
          }
        } else {
          // Cas 2 : Pas besoin d'OTP (utilisateur existant avec infos complètes ou auto-vérification)
          // Attendre un peu pour s'assurer que l'état est mis à jour
          await Future.delayed(const Duration(milliseconds: 100));

          // Vérifier si l'utilisateur est authentifié
          final authState = ref.read(authProvider);
          print(
              '🔍 DEBUG: authState.isAuthenticated = ${authState.isAuthenticated}');
          print('🔍 DEBUG: authState.currentUser = ${authState.currentUser}');

          if (authState.isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connexion réussie !'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Forcer le rafraîchissement du HomeProvider
            print('🔄 Forçage du rafraîchissement du HomeProvider');
            await ref.read(homeProvider.notifier).refreshUser();

            // Navigation directe vers le dashboard
            if (mounted) {
              print('🔍 DEBUG: Navigation vers /home');
              context.router.push(HomeRoute());
            }
          } else {
            // Cas d'auto-vérification Firebase - navigation vers localisation
            print(
                '🔍 DEBUG: Navigation vers /share-location (auto-vérification)');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connexion réussie !'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            if (mounted) {
              context.router.push(HomeRoute());
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur: ${e.toString()}';

        // Nettoyer les données locales en cas d'erreur non-réseau
        if (!e.toString().toLowerCase().contains('network') &&
            !e.toString().toLowerCase().contains('connection')) {
          await _connectionManager.clearOfflineData();
        }

        // Messages d'erreur plus spécifiques
        if (e.toString().contains('blocked all requests')) {
          errorMessage =
              'Appareil temporairement bloqué. Attendez quelques minutes ou utilisez un autre appareil.';
        } else if (e.toString().contains('invalid-phone-number')) {
          errorMessage =
              'Numéro de téléphone invalide. Vérifiez le format (0701234567).';
        } else if (e.toString().contains('quota-exceeded')) {
          errorMessage = 'Limite de SMS dépassée. Réessayez plus tard.';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'Erreur réseau. Vérifiez votre connexion internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écoute les changements d'état du AuthProvider pour afficher les messages d'erreur
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.orange.shade700, // Couleur de fond du Scaffold
      resizeToAvoidBottomInset:
          true, // Permet au contenu de se redimensionner quand le clavier s'ouvre
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade700, Colors.deepOrange.shade900],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: [
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
            SingleChildScrollView(
              child: Column(
                children: [
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "VEUILLEZ SAISIR VOTRE NUMERO S'IL VOUS PLAÎT",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.bold),
                        ),
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
                            prefixText:
                                "", // Pas de préfixe pour éviter la suppression du 0
                            paddingLeft: 12,
                            keyboardType: TextInputType.phone,
                            placeholder:
                                "0707070707", // Placeholder pour guider l'utilisateur
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Saisissez votre numéro complet (ex: 0701234567)",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (authState.errorMessage != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
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
                  // Espace en bas pour éviter que le contenu soit caché par le clavier
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
