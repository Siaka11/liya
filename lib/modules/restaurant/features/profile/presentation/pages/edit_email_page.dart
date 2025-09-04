import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:liya/core/services/user_profile_service.dart';
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';

@RoutePage()
class EditEmailPage extends ConsumerStatefulWidget {
  final String currentEmail;
  final String userId;

  const EditEmailPage({
    Key? key,
    required this.currentEmail,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends ConsumerState<EditEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  final UserProfileService _profileService = UserProfileService();
  final ConnectionManager _connectionManager = ConnectionManager();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isVerifying = false;
  bool _showPasswordField = false;

  @override
  void initState() {
    super.initState();
    _newEmailController.text = widget.currentEmail;

    // Définir le contexte pour le gestionnaire de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    _connectionManager.clearCurrentContext();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final newEmail = _newEmailController.text.trim();
    if (newEmail == widget.currentEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nouvel email est identique à l\'actuel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si l'email est déjà utilisé
      final isEmailUsed = await _profileService.isEmailAlreadyUsed(
        newEmail,
        excludeUserId: widget.userId,
      );

      if (isEmailUsed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cet email est déjà utilisé par un autre compte'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Préparer les données de mise à jour
      final updateData = {
        'email': newEmail,
        'userId': widget.userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Sauvegarder les données localement
      await _connectionManager.saveRegistrationData(updateData);

      // Exécuter la mise à jour avec gestion de connexion
      await _connectionManager.executeWithConnectionHandling(
        () => _profileService.updateUserEmail(widget.userId, newEmail),
        operationType: 'email_update',
        fallbackData: updateData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Nettoyer les données locales après succès
        await _connectionManager.clearOfflineData();

        // Retourner à la page précédente
        context.router.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur lors de la mise à jour';

        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'Cet email est déjà utilisé';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Format d\'email invalide';
        } else if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Veuillez vous reconnecter pour modifier votre email';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre mot de passe'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email != null) {
        // Recréer l'utilisateur avec l'email actuel et le mot de passe
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: _passwordController.text,
        );

        await currentUser.reauthenticateWithCredential(credential);

        setState(() {
          _showPasswordField = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe vérifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Modifier l\'email',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Widget de statut de connexion
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ConnectionStatusWidget(
                showWhenConnected: false,
                showWhenDisconnected: true,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre
              const Text(
                'Modification de l\'email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La modification de l\'email nécessite une vérification de sécurité.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Champ Email actuel
              _buildTextField(
                controller: TextEditingController(text: widget.currentEmail),
                label: 'Email actuel',
                icon: Icons.email,
                enabled: false,
              ),

              const SizedBox(height: 16),

              // Champ Nouvel email
              _buildTextField(
                controller: _newEmailController,
                label: 'Nouvel email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nouvel email';
                  }
                  if (!_profileService.isValidEmail(value)) {
                    return 'Format d\'email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ Mot de passe (si nécessaire)
              if (_showPasswordField) ...[
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe actuel',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Bouton de vérification
                OutlinedButton(
                  onPressed: _isVerifying ? null : _verifyPassword,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF24E1E),
                    side: const BorderSide(color: Color(0xFFF24E1E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isVerifying
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF24E1E)),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Vérification...'),
                          ],
                        )
                      : const Text('Vérifier le mot de passe'),
                ),

                const SizedBox(height: 16),
              ],

              // Bouton de mise à jour
              ElevatedButton(
                onPressed: _isLoading ? null : _updateEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Mise à jour en cours...'),
                        ],
                      )
                    : const Text(
                        'Mettre à jour l\'email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Message d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Un email de confirmation sera envoyé à votre nouvelle adresse.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF24E1E)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFF24E1E),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
      ),
    );
  }
}
