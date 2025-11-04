import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/core/services/user_profile_service.dart';
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';

@RoutePage()
class EditPhonePage extends ConsumerStatefulWidget {
  final String currentPhone;
  final String userId;

  const EditPhonePage({
    Key? key,
    required this.currentPhone,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends ConsumerState<EditPhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _newPhoneController = TextEditingController();

  final UserProfileService _profileService = UserProfileService();
  final ConnectionManager _connectionManager = ConnectionManager();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPhoneController.text = widget.currentPhone;

    // Définir le contexte pour le gestionnaire de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
  }

  @override
  void dispose() {
    _newPhoneController.dispose();
    _connectionManager.clearCurrentContext();
    super.dispose();
  }

  Future<void> _updatePhone() async {
    if (!_formKey.currentState!.validate()) return;

    final newPhone = _newPhoneController.text.trim();
    if (newPhone == widget.currentPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nouveau numéro est identique à l\'actuel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si le numéro est déjà utilisé
      final isPhoneUsed = await _profileService.isPhoneNumberAlreadyUsed(
        newPhone,
        excludeUserId: widget.userId,
      );

      if (isPhoneUsed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ce numéro est déjà utilisé par un autre compte'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Préparer les données de mise à jour
      final updateData = {
        'phoneNumber': newPhone,
        'userId': widget.userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Sauvegarder les données localement
      await _connectionManager.saveRegistrationData(updateData);

      // Exécuter la mise à jour avec gestion de connexion
      await _connectionManager.executeWithConnectionHandling(
        () => _profileService.updateUserPhoneNumber(widget.userId, newPhone),
        operationType: 'phone_update',
        fallbackData: updateData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de téléphone mis à jour avec succès !'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Modifier le numéro',
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
                'Modification du numéro de téléphone',
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
                        'Assurez-vous que le nouveau numéro est correct et accessible.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Champ Numéro actuel
              _buildTextField(
                controller: TextEditingController(text: widget.currentPhone),
                label: 'Numéro actuel',
                icon: Icons.phone,
                enabled: false,
              ),

              const SizedBox(height: 16),

              // Champ Nouveau numéro
              _buildTextField(
                controller: _newPhoneController,
                label: 'Nouveau numéro de téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nouveau numéro';
                  }
                  if (!_profileService.isValidPhoneNumber(value)) {
                    return 'Format invalide (ex: 0701234567)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Bouton de mise à jour
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePhone,
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
                        'Mettre à jour le numéro',
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
                        'Le changement de numéro peut affecter la réception des notifications.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
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
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
