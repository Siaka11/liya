import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../core/services/dish_popularity_service.dart';

// Niveaux de popularité prédéfinis - TOUS COMMENCENT PAR 0
enum PopularityLevel {
  nouveau('Nouveau plat', 0, 0, 0.0);
/*  standard('Plat standard', 0, 0, 0.0),
  apprecie('Plat apprécié', 0, 0, 0.0),
  populaire('Plat populaire', 0, 0, 0.0),
  tendance('En tendance', 0, 0, 0.0),
  bestseller('Best-seller', 0, 0, 0.0);*/

  const PopularityLevel(
      this.label, this.orderCount, this.viewCount, this.rating);

  final String label;
  final int orderCount;
  final int viewCount;
  final double rating;
}

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
  String? _selectedPopularity; // Niveau de popularité initial

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
    // Validation
    if (_selectedRestaurantId == null ||
        _selectedCategoryId == null ||
        _selectedPopularity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Veuillez sélectionner un restaurant, une catégorie et un niveau de popularité')),
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

      // Récupérer les données de popularité basées sur la sélection
      final selectedLevel = PopularityLevel.values
          .firstWhere((level) => level.name == _selectedPopularity);

      // Créer le plat selon la structure de l'image
      final dishData = {
        'restaurant_id': _selectedRestaurantId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'image_url': imageUrl ?? '',
        'rating':
            selectedLevel.rating, // Utiliser le rating du niveau de popularité
        'categorie': _categories
            .firstWhere((c) => c['id'] == _selectedCategoryId)['name'],
        'preparation_time': _preparationTimeController.text.trim(),
        'sodas': int.tryParse(_sodasController.text) ?? 0,
        'isAvailable': true, // Nouveau plat disponible par défaut
        // Données de popularité initiales
        'order_count': selectedLevel.orderCount,
        'view_count': selectedLevel.viewCount,
        'rating_count': selectedLevel.orderCount > 0
            ? (selectedLevel.orderCount / 3).round()
            : 0, // Estimation du nombre d'avis
        'popularity_score': DishPopularityService.calculatePopularityScore({
          'order_count': selectedLevel.orderCount,
          'view_count': selectedLevel.viewCount,
          'rating': selectedLevel.rating,
          'rating_count': selectedLevel.orderCount > 0
              ? (selectedLevel.orderCount / 3).round()
              : 0,
          'last_ordered': selectedLevel.orderCount > 0 ? DateTime.now() : null,
        }),
        'last_ordered':
            selectedLevel.orderCount > 0 ? FieldValue.serverTimestamp() : null,
        'last_viewed':
            selectedLevel.viewCount > 0 ? FieldValue.serverTimestamp() : null,
        // Timestamps
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
                          const SizedBox(height: 16),

                          // Popularité initiale
                          DropdownButtonFormField<String>(
                            value: _selectedPopularity,
                            decoration: InputDecoration(
                              labelText: 'Popularité initiale *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.trending_up),
                              filled: true,
                              fillColor: Colors.grey[50],
                              helperText:
                                  'Définit les statistiques initiales du plat',
                            ),
                            items: PopularityLevel.values.map((level) {
                              return DropdownMenuItem<String>(
                                value: level.name,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icône selon le niveau
                                    Icon(
                                      _getPopularityIcon(level),
                                      color: _getPopularityColor(level),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            level.label,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          /*Text(
                                            '${level.orderCount} commandes • ${level.rating}⭐',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),*/
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPopularity = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner un niveau de popularité';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Aperçu de la popularité sélectionnée
                         /* if (_selectedPopularity != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: _buildPopularityPreview(),
                            ),
                          const SizedBox(height: 24),*/

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
/*                          TextFormField(
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
                          ),*/
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

  IconData _getPopularityIcon(PopularityLevel level) {
    switch (level) {
      case PopularityLevel.nouveau:
        return Icons.new_releases;
      /*case PopularityLevel.standard:
        return Icons.star_border;
      case PopularityLevel.apprecie:
        return Icons.thumb_up_alt_outlined;
      case PopularityLevel.populaire:
        return Icons.trending_up;
      case PopularityLevel.tendance:
        return Icons.trending_up;
      case PopularityLevel.bestseller:
        return Icons.star;*/
    }
  }

  Color _getPopularityColor(PopularityLevel level) {
    switch (level) {
      case PopularityLevel.nouveau:
        return Colors.green;
      /*case PopularityLevel.standard:
        return Colors.orange;
      case PopularityLevel.apprecie:
        return Colors.green;
      case PopularityLevel.populaire:
        return Colors.purple;
      case PopularityLevel.tendance:
        return Colors.indigo;
      case PopularityLevel.bestseller:
        return Colors.red;*/
    }
  }

  Widget _buildPopularityPreview() {
    if (_selectedPopularity == null) return const SizedBox.shrink();

    final selectedLevel = PopularityLevel.values
        .firstWhere((level) => level.name == _selectedPopularity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility,
              size: 16,
              color: Colors.blue[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Aperçu du plat avec cette popularité',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Badge de popularité simulé
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPopularityColor(selectedLevel),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPopularityIcon(selectedLevel),
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    selectedLevel.label
                        .split(' ')
                        .last, // Prendre le dernier mot
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Statistiques
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⭐ ${selectedLevel.rating.toStringAsFixed(1)} • ${selectedLevel.orderCount} commandes',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '👁️ ${selectedLevel.viewCount} vues',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
