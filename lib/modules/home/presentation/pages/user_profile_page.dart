import 'dart:convert';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/local_storage_factory.dart';
import '../../../../../core/singletons.dart';
import '../../../../../core/services/phone_call_service.dart';
import '../../../../../core/services/account_management_service.dart';
import '../../../../../core/test_firebase_auth_deletion.dart';

@RoutePage()
class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;

    setState(() {
      _nameController.text = userDetails['name'] ?? '';
      _lastnameController.text = userDetails['lastName'] ?? '';
      _emailController.text = userDetails['email'] ?? '';
      _addressController.text = userDetails['address'] ?? '';
      _phoneController.text = userDetails['phoneNumber'] ?? '';
      _currentImageUrl = userDetails['profileImageUrl'];
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      final fileName =
          'profile_${phoneNumber}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      final uploadTask = ref.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      // Upload de l'image si sélectionnée
      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
      }

      // Mettre à jour dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .update({
        'name': _nameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le stockage local
      final updatedUserDetails = {
        ...userDetails,
        'name': _nameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
      };

      await singleton<LocalStorageFactory>().setUserDetails(
        updatedUserDetails,
      );

      setState(() {
        _isEditing = false;
        _selectedImage = null;
        _currentImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _callNumber(BuildContext context, String number) async {
    try {
      debugPrint('Tentative d\'appel vers: $number');
      final success = await PhoneCallService.makeCall(number);
      if (!success) {
        _showCopySnackBar(context, number);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'appel : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCopySnackBar(BuildContext context, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Impossible d\'ouvrir l\'application Téléphone.\nNuméro : $number'),
        action: SnackBarAction(
          label: 'Copier',
          onPressed: () async {
            await PhoneCallService.copyToClipboard(number);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Numéro copié dans le presse-papiers'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (_isEditing)
            IconButton(
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
            ),
          if (_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _selectedImage = null;
                });
                _loadUserData(); // Recharger les données originales
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Section Photo de profil
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Photo de profil
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              const Color(0xFFF24E1E).withOpacity(0.1),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_currentImageUrl != null &&
                                      _currentImageUrl!.isNotEmpty)
                                  ? NetworkImage(_currentImageUrl!)
                                  : null,
                          child: _selectedImage == null &&
                                  (_currentImageUrl == null ||
                                      _currentImageUrl!.isEmpty)
                              ? Text(
                                  (_nameController.text.isNotEmpty
                                      ? _nameController.text[0].toUpperCase()
                                      : 'U'),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF24E1E),
                                  ),
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF24E1E),
                                shape: BoxShape.circle,
                              ),
                              child: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onSelected: (value) {
                                  if (value == 'gallery') {
                                    _pickImage();
                                  } else if (value == 'camera') {
                                    _takePhoto();
                                  } else if (value == 'remove') {
                                    setState(() {
                                      _selectedImage = null;
                                      _currentImageUrl = null;
                                    });
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'gallery',
                                    child: Row(
                                      children: [
                                        Icon(Icons.photo_library),
                                        SizedBox(width: 8),
                                        Text('Galerie'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'camera',
                                    child: Row(
                                      children: [
                                        Icon(Icons.camera_alt),
                                        SizedBox(width: 8),
                                        Text('Appareil photo'),
                                      ],
                                    ),
                                  ),
                                  if (_currentImageUrl != null &&
                                      _currentImageUrl!.isNotEmpty)
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Supprimer',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Photo de profil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Informations personnelles
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF24E1E),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nom
                    TextFormField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Prénom *',
                        hintText: 'Entrez votre prénom',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            _isEditing ? Colors.grey[50] : Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir votre prénom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nom de famille
                    TextFormField(
                      controller: _lastnameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: 'Nom de famille',
                        hintText: 'Entrez votre nom de famille',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            _isEditing ? Colors.grey[50] : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Entrez votre email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            _isEditing ? Colors.grey[50] : Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Veuillez saisir un email valide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Adresse
                    TextFormField(
                      controller: _addressController,
                      enabled: _isEditing,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Adresse',
                        hintText: 'Entrez votre adresse',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            _isEditing ? Colors.grey[50] : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Numéro de téléphone (grisé)
                    TextFormField(
                      controller: _phoneController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: const Icon(Icons.lock, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.phone,
                      title: 'Appeler le support',
                      subtitle: '+225 07 00 84 65 46',
                      onTap: () => _callNumber(context, '+2250700846546'),
                    ),
                   /* const Divider(),
                    // Bouton de test temporaire
                    _buildActionTile(
                      icon: Icons.bug_report,
                      title: 'Test suppression Firebase Auth',
                      subtitle: 'Vérifier la suppression (DEBUG)',
                      isDestructive: true,
                      onTap: () async {
                        final localStorage = LocalStorageFactory();
                        final userDetails = localStorage.getUserDetails();
                        if (userDetails != null) {
                          final phoneNumber =
                              jsonDecode(userDetails)['phoneNumber'];
                          await FirebaseAuthDeletionTest
                              .testCompleteUserDeletion(phoneNumber);
                        }
                      },
                    ),*/
                    const Divider(),
                    _buildActionTile(
                      icon: Icons.logout,
                      title: 'Déconnexion',
                      subtitle: 'Se déconnecter de l\'application',
                      isDestructive: true,
                      onTap: () async {
                        AccountManagementService.showLogoutDialog(context);
                      },
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFFF24E1E),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
