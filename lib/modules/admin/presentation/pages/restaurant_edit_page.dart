import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/image_upload_service.dart';

@RoutePage()
class RestaurantEditPage extends StatefulWidget {
  final String? restaurantId;
  const RestaurantEditPage({Key? key, this.restaurantId}) : super(key: key);

  @override
  State<RestaurantEditPage> createState() => _RestaurantEditPageState();
}

class _RestaurantEditPageState extends State<RestaurantEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isSaving = false;
  bool isActive = true;
  String? imageUrl;
  String? selectedImagePath;

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  Map<String, String> openingHours = {
    'mon': '11:00-22:00',
    'tue': '11:00-22:00',
    'wed': '11:00-22:00',
    'thu': '11:00-22:00',
    'fri': '11:00-23:00',
    'sat': '11:00-23:00',
    'sun': '12:00-21:00',
  };

  @override
  void initState() {
    super.initState();
    if (widget.restaurantId != null) {
      _loadRestaurant();
    }
  }

  Future<void> _loadRestaurant() async {
    setState(() => isLoading = true);
    final doc = await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      descriptionController.text = data['description'] ?? '';
      addressController.text = data['address'] ?? '';
      cityController.text = data['city'] ?? '';
      phoneController.text = data['phone'] ?? '';
      emailController.text = data['email'] ?? '';
      latitudeController.text = data['latitude']?.toString() ?? '';
      longitudeController.text = data['longitude']?.toString() ?? '';
      imageUrl = data['coverImage'] ?? '';
      isActive = data['isActive'] ?? true;
      if (data['openingHours'] != null) {
        openingHours = Map<String, String>.from(data['openingHours']);
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
        imageUrl = null;
      });
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);
    try {
      String? uploadedImageUrl = imageUrl;
      if (selectedImagePath != null) {
        uploadedImageUrl = await ImageUploadService.uploadImage(selectedImagePath!, 'restaurants');
      }
      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'latitude': double.tryParse(latitudeController.text) ?? 0.0,
        'longitude': double.tryParse(longitudeController.text) ?? 0.0,
        'coverImage': uploadedImageUrl ?? '',
        'isActive': isActive,
        'openingHours': openingHours,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.restaurantId != null) {
        await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('restaurants').add(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant sauvegardé avec succès'), backgroundColor: Colors.green),
        );
        context.router.pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantId != null ? 'Modifier le restaurant' : 'Ajouter un restaurant'),
        backgroundColor: const Color(0xFFF24E1E),
        actions: [
          if (widget.restaurantId != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: isSaving
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer'),
                          content: const Text('Supprimer ce restaurant ?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseFirestore.instance.collection('restaurants').doc(widget.restaurantId).delete();
                        if (mounted) context.router.pop(true);
                      }
                    },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // IMAGE
                  Center(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: selectedImagePath != null
                              ? Image.file(File(selectedImagePath!), width: 120, height: 120, fit: BoxFit.cover)
                              : (imageUrl != null && imageUrl!.isNotEmpty)
                                  ? Image.network(imageUrl!, width: 120, height: 120, fit: BoxFit.cover)
                                  : Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.restaurant, size: 60, color: Colors.grey),
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: isSaving ? null : _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.camera_alt, color: Color(0xFFF24E1E)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // SECTION INFOS PRINCIPALES
                  const Text('Informations principales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  // SECTION CONTACT
                  const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adresse *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Adresse requise' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Ville *', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ville requise' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  // SECTION LOCALISATION
                  const Text('Localisation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latitudeController,
                          decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: longitudeController,
                          decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // SECTION HORAIRES
                  const Text('Horaires d\'ouverture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...openingHours.entries.map((entry) {
                    final day = entry.key;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 80, child: Text(_getDayName(day))),
                          Expanded(
                            child: TextFormField(
                              initialValue: entry.value,
                              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'ex: 11:00-22:00'),
                              onChanged: (v) => openingHours[day] = v,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // SECTION STATUT
                  Row(
                    children: [
                      Switch(
                        value: isActive,
                        onChanged: isSaving ? null : (v) => setState(() => isActive = v),
                        activeColor: const Color(0xFFF24E1E),
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Actif' : 'Inactif', style: TextStyle(color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // BOUTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveRestaurant,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF24E1E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving ? null : () => context.router.pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFF24E1E)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Annuler', style: TextStyle(color: Color(0xFFF24E1E), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getDayName(String day) {
    switch (day) {
      case 'mon': return 'Lundi';
      case 'tue': return 'Mardi';
      case 'wed': return 'Mercredi';
      case 'thu': return 'Jeudi';
      case 'fri': return 'Vendredi';
      case 'sat': return 'Samedi';
      case 'sun': return 'Dimanche';
      default: return day;
    }
  }
} 