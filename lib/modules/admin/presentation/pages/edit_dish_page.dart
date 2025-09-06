import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

@RoutePage()
class EditDishPage extends StatefulWidget {
  final String dishId;
  final Map<String, dynamic> dishData;

  const EditDishPage({
    Key? key,
    required this.dishId,
    required this.dishData,
  }) : super(key: key);

  @override
  State<EditDishPage> createState() => _EditDishPageState();
}

class _EditDishPageState extends State<EditDishPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _sodasController = TextEditingController();
  final _ratingController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedRestaurantId;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _categories = [];
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _preparationTimeController.dispose();
    _sodasController.dispose();
    _ratingController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Initialiser les contrôleurs avec les données existantes
    _nameController.text = widget.dishData['name'] ?? '';
    _descriptionController.text = widget.dishData['description'] ?? '';
    _priceController.text = (widget.dishData['price'] ?? 0.0).toString();
    _preparationTimeController.text = widget.dishData['preparation_time'] ?? '';
    //_ratingController.text = (widget.dishData['rating'] ?? 0.0).toString();
    _imageUrlController.text = widget.dishData['image_url'] ?? '';
    _selectedRestaurantId = widget.dishData['restaurant_id'] ?? '';
    _selectedCategoryId = widget.dishData['categorie'] ?? '';

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les restaurants
      final restaurantSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      _restaurants = restaurantSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Nom inconnu',
        };
      }).toList();

      // Charger les catégories
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      _categories = categorySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'Catégorie inconnue',
              'description': data['description'] ?? '',
              'isActive': data['isActive'] ?? true,
            };
          })
          .where((category) => category['isActive'] == true)
          .toList();

      // S'assurer que les valeurs sélectionnées sont valides
      if (_selectedRestaurantId != null &&
          !_restaurants.any((r) => r['id'] == _selectedRestaurantId)) {
        _selectedRestaurantId = null;
      }
      if (_selectedCategoryId != null &&
          !_categories.any((c) => c['name'] == _selectedCategoryId)) {
        _selectedCategoryId = null;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
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

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final fileName = 'dish_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('dishes/$fileName');
      final uploadTask = ref.putFile(_selectedImage!);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  Future<void> _saveDish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRestaurantId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Veuillez sélectionner un restaurant et une catégorie')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Upload de l'image si sélectionnée
      String? imageUrl;
      if (_selectedImage != null) {
        // Si une nouvelle image est sélectionnée, l'uploader
        imageUrl = await _uploadImage();
      } else if (_imageUrlController.text.isNotEmpty) {
        // Sinon, utiliser l'URL fournie
        imageUrl = _imageUrlController.text;
      } else {
        // Garder l'image existante
        imageUrl = widget.dishData['image_url'] ?? '';
      }

      // Mettre à jour le plat
      final dishData = {
        'restaurant_id': _selectedRestaurantId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'image_url': imageUrl ?? widget.dishData['image_url'] ?? '',
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
        'categorie': _selectedCategoryId,
        'preparation_time': _preparationTimeController.text.trim(),
        'sodas': int.tryParse(_sodasController.text) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('dishes')
          .doc(widget.dishId)
          .update(dishData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plat modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // Retour avec succès
    } catch (e) {
      print('Erreur lors de la modification du plat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF24E1E), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF24E1E),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Modifier le Plat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Informations de base
                    _buildSectionHeader('Informations de base', Icons.info),
                    const SizedBox(height: 16),

                    // Nom du plat
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du plat *',
                        hintText: 'Ex: Poulet Braisé',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.restaurant_menu),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir le nom du plat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description ',
                        hintText: 'Décrivez le plat...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Restaurant et Catégorie
                    _buildSectionHeader('Restaurant et Catégorie', Icons.store),
                    const SizedBox(height: 16),

                    // Restaurant
                    DropdownButtonFormField<String>(
                      value: _selectedRestaurantId,
                      decoration: InputDecoration(
                        labelText: 'Restaurant *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.store),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _restaurants.map((restaurant) {
                        return DropdownMenuItem<String>(
                          value: restaurant['id'],
                          child: Text(restaurant['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRestaurantId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un restaurant';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Catégorie *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['name'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section Détails
                    _buildSectionHeader('Détails', Icons.settings),
                    const SizedBox(height: 16),

                    // Prix
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prix (CFA) *',
                        hintText: 'Ex: 12.50',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.price_change),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir le prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez saisir un prix valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Temps de préparation
                    TextFormField(
                      controller: _preparationTimeController,
                      decoration: InputDecoration(
                        labelText: 'Temps de préparation',
                        hintText: 'Ex: 2h, 1h30min, 30min',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre de sodas
                    /*TextFormField(
                      controller: _sodasController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de sodas',
                        hintText: 'Ex: 1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.local_drink),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),*/

                    // Note
                    /*TextFormField(
                      controller: _ratingController,
                      decoration: InputDecoration(
                        labelText: 'Note',
                        hintText: 'Ex: 4.5',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.star),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                    ),*/
                    const SizedBox(height: 24),

                    // Section Image
                    _buildSectionHeader('Image du plat', Icons.image),
                    const SizedBox(height: 16),

                    // Aperçu de l'image actuelle
                    if (widget.dishData['image_url'] != null &&
                        widget.dishData['image_url'].isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.dishData['image_url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    if (widget.dishData['image_url'] != null &&
                        widget.dishData['image_url'].isNotEmpty)
                      const SizedBox(height: 32),

                    // Aperçu de la nouvelle image sélectionnée
                    if (_selectedImage != null)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    if (_selectedImage != null) const SizedBox(height: 16),

                    // Boutons pour l'image
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text('Changer l\'image'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                                _imageUrlController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Effacer'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.dishData['image_url'] != null &&
                            widget.dishData['image_url'].isNotEmpty)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _imageUrlController.clear();
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Supprimer',
                                  style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // URL de l'image (alternative)
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL de l\'image (optionnel)',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              side: const BorderSide(color: Color(0xFFF24E1E)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                color: Color(0xFFF24E1E),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveDish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF24E1E),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
