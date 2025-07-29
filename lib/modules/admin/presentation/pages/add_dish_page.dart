import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

@RoutePage()
class AddDishPage extends StatefulWidget {
  const AddDishPage({Key? key}) : super(key: key);

  @override
  State<AddDishPage> createState() => _AddDishPageState();
}

class _AddDishPageState extends State<AddDishPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  final _sodasController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ratingController = TextEditingController();

  // Variables nullable pour éviter l'erreur DropdownButton
  String? _selectedRestaurantId;
  String? _selectedCategoryId;

  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _preparationTimeController.dispose();
    _sodasController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    super.dispose();
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
          'name': doc.data()['name'] ?? 'Restaurant inconnu',
        };
      }).toList();

      // Charger les catégories avec leurs images
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      print(
          '📊 Nombre de catégories trouvées dans Firestore: ${categorySnapshot.docs.length}');

      _categories = categorySnapshot.docs
          .map((doc) {
            final data = doc.data();
            final category = {
              'id': doc.id,
              'name': data['name'] ?? 'Catégorie inconnue',
              'description': data['description'] ?? '',
              'imageUrl': data['imageUrl'] ?? '',
              'isActive': data['isActive'] ?? true,
            };
            print(
                '🏷️ Catégorie chargée: ${category['name']} (ID: ${category['id']}, Active: ${category['isActive']})');
            return category;
          })
          .where((category) => category['isActive'] == true)
          .toList(); // Filtrer seulement les catégories actives

      print(
          '✅ Nombre de catégories actives après filtrage: ${_categories.length}');
      print(
          '📋 Catégories disponibles: ${_categories.map((c) => c['name']).toList()}');

      // S'assurer que les valeurs sélectionnées sont valides ou null
      if (_selectedRestaurantId != null &&
          !_restaurants.any((r) => r['id'] == _selectedRestaurantId)) {
        _selectedRestaurantId = null;
      }
      if (_selectedCategoryId != null &&
          !_categories.any((c) => c['id'] == _selectedCategoryId)) {
        _selectedCategoryId = null;
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      String? imageUrl = _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : await _uploadImage();

      // Créer le plat selon la structure de l'image
      final dishData = {
        'restaurant_id': _selectedRestaurantId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'image_url': imageUrl ?? '',
        'rating': double.tryParse(_ratingController.text) ?? 0.0,
        'categorie': _categories
            .firstWhere((c) => c['id'] == _selectedCategoryId)['name'],
        'preparation_time': _preparationTimeController.text.trim(),
        'sodas': int.tryParse(_sodasController.text) ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('dishes').add(dishData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plat ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner à la page de gestion des plats
      Navigator.of(context).pop();
    } catch (e) {
      print('Erreur lors de l\'ajout du plat: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Plat'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header avec titre
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF24E1E),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nouveau Plat',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ajoutez un nouveau plat à votre menu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Formulaire
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Informations de base
                          _buildSectionHeader(
                              'Informations de base', Icons.info),
                          const SizedBox(height: 16),

                          // Nom du plat
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom du plat *',
                              hintText: 'Ex: Riz + poisson fumé',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.restaurant),
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
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Description détaillée du plat',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.description),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Prix
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: 'Prix (FCFA) *',
                              hintText: 'Ex: 1100',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.attach_money),
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

                          // Rating
                          TextFormField(
                            controller: _ratingController,
                            decoration: InputDecoration(
                              labelText: 'Note (0-5)',
                              hintText: 'Ex: 4.5',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.star),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final rating = double.tryParse(value);
                                if (rating == null ||
                                    rating < 0 ||
                                    rating > 5) {
                                  return 'La note doit être entre 0 et 5';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Section Catégorisation
                          _buildSectionHeader('Catégorisation', Icons.category),
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
                                value: category['id'],
                                child: Row(
                                  children: [
                                    // Image de la catégorie
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: category['imageUrl'] != null &&
                                                category['imageUrl']
                                                    .toString()
                                                    .isNotEmpty
                                            ? Image.network(
                                                category['imageUrl'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons.category,
                                                        color: Colors.grey,
                                                        size: 16),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                    Icons.category,
                                                    color: Colors.grey,
                                                    size: 16),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category['name'],
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
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
                          TextFormField(
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
                          const SizedBox(height: 24),

                          // Section Image
                          _buildSectionHeader('Image du plat', Icons.image),
                          const SizedBox(height: 16),

                          // Aperçu de l'image sélectionnée
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

                          if (_selectedImage != null)
                            const SizedBox(height: 16),

                          // Boutons pour l'image
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.image),
                                  label: const Text('Sélectionner une image'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Effacer'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    side: const BorderSide(
                                        color: Color(0xFFF24E1E)),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Ajouter le Plat',
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
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF24E1E), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
