import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/core/services/user_profile_service.dart';
import 'package:liya/core/services/connection_manager.dart';
import 'package:liya/core/ui/widgets/connection_status_widget.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'dart:convert';

@RoutePage()
class EditProfilePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditProfilePage({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final UserProfileService _profileService = UserProfileService();
  final ConnectionManager _connectionManager = ConnectionManager();

  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();

    // Définir le contexte pour le gestionnaire de connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionManager.setCurrentContext(context);
    });
  }

  void _initializeData() {
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _lastNameController.text = widget.initialData!['lastName'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phoneNumber'] ?? '';
      _addressController.text = widget.initialData!['address'] ?? '';
      _userId = widget.initialData!['id'] ?? widget.initialData!['uid'];
    } else {
      // Récupérer les données depuis le stockage local
      _loadUserDataFromLocal();
    }
  }

  void _loadUserDataFromLocal() {
    try {
      final userDetailsJson = LocalStorageFactory().getUserDetails();
      if (userDetailsJson != null) {
        final userDetails = userDetailsJson is String
            ? jsonDecode(userDetailsJson)
            : userDetailsJson;

        _nameController.text = userDetails['name'] ?? '';
        _lastNameController.text = userDetails['lastName'] ?? '';
        _emailController.text = userDetails['email'] ?? '';
        _phoneController.text = userDetails['phoneNumber'] ?? '';
        _addressController.text = userDetails['address'] ?? '';
        _userId = userDetails['uid'] ?? userDetails['id'];
      }
    } catch (e) {
      print('❌ Erreur chargement données locales: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _connectionManager.clearCurrentContext();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: ID utilisateur non trouvé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Préparer les données de mise à jour
      final updateData = {
        'name': _nameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Sauvegarder les données localement
      await _connectionManager.saveRegistrationData(updateData);

      // Exécuter la mise à jour avec gestion de connexion
      await _connectionManager.executeWithConnectionHandling(
        () => _profileService.updateUserProfile(_userId!, {
          'name': _nameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        }),
        operationType: 'profile_update',
        fallbackData: updateData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
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
          'Modifier le profil',
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
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Champ Nom
              _buildTextField(
                controller: _nameController,
                label: 'Nom',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  if (!_profileService.isValidName(value)) {
                    return 'Nom invalide (au moins 2 caractères)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ Prénom
              _buildTextField(
                controller: _lastNameController,
                label: 'Prénom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (!_profileService.isValidName(value!)) {
                    return 'Prénom invalide (au moins 2 caractères)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ Téléphone
              _buildTextField(
                controller: _phoneController,
                label: 'Numéro de téléphone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Champ Adresse
              _buildTextField(
                controller: _addressController,
                label: 'Adresse',
                icon: Icons.location_on,
                maxLines: 3,
                validator: (value) {
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Bouton de sauvegarde
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
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
                        'Sauvegarder les modifications',
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
                        'Vos modifications sont sauvegardées localement en cas de perte de connexion.',
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF24E1E)),
        filled: true,
        fillColor: Colors.white,
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
