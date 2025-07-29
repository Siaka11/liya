import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

@RoutePage()
class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({Key? key}) : super(key: key);

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore.collection('categories').get();
      _categories = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((category) {
      return category['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          category['description']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showAddEditCategoryDialog(
      [Map<String, dynamic>? category]) async {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    final descriptionController =
        TextEditingController(text: category?['description'] ?? '');
    File? selectedImage;
    String? imageUrl = category?['imageUrl'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null
              ? 'Ajouter une catégorie'
              : 'Modifier la catégorie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nom de la catégorie
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la catégorie *',
                    hintText: 'Ex: Ivoirien, Europe, Afrique',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le nom de la catégorie';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Description de la catégorie',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Section Image
                const Text(
                  'Image de la catégorie',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Aperçu de l'image
                if (selectedImage != null || imageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                );
                              },
                            ),
                    ),
                  ),

                if (selectedImage != null || imageUrl != null)
                  const SizedBox(height: 12),

                // Boutons pour l'image
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 512,
                            maxHeight: 512,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              selectedImage = File(image.path);
                              imageUrl =
                                  null; // Effacer l'URL si une nouvelle image est sélectionnée
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Sélectionner'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedImage = null;
                            imageUrl = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Effacer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Veuillez saisir le nom de la catégorie')),
                  );
                  return;
                }

                try {
                  // Upload de l'image si sélectionnée
                  String? finalImageUrl = imageUrl;
                  if (selectedImage != null) {
                    final fileName =
                        'category_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final ref = _storage.ref().child('categories/$fileName');
                    final uploadTask = ref.putFile(selectedImage!);
                    final snapshot = await uploadTask;
                    finalImageUrl = await snapshot.ref.getDownloadURL();
                  }

                  final categoryData = {
                    'name': nameController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'imageUrl': finalImageUrl ?? '',
                    'isActive': true,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };

                  if (category == null) {
                    // Ajouter une nouvelle catégorie
                    categoryData['createdAt'] = FieldValue.serverTimestamp();
                    await _firestore.collection('categories').add(categoryData);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Catégorie ajoutée avec succès')),
                    );
                  } else {
                    // Modifier la catégorie existante
                    await _firestore
                        .collection('categories')
                        .doc(category['id'])
                        .update(categoryData);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Catégorie modifiée avec succès')),
                    );
                  }

                  _loadCategories(); // Recharger les données
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              },
              child: Text(category == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(String categoryId, String categoryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous vraiment supprimer la catégorie "$categoryName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('categories').doc(categoryId).delete();
        _loadCategories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catégorie supprimée avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Catégories'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher une catégorie...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Statistiques
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard(
                          'Total', _categories.length.toString(), Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          'Actives',
                          _categories
                              .where((c) => c['isActive'] == true)
                              .length
                              .toString(),
                          Colors.green),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          'Inactives',
                          _categories
                              .where((c) => c['isActive'] == false)
                              .length
                              .toString(),
                          Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Liste des catégories
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune catégorie trouvée',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            return _buildCategoryCard(category);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCategoryDialog(),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image de la catégorie
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: category['imageUrl'] != null &&
                        category['imageUrl'].toString().isNotEmpty
                    ? Image.network(
                        category['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child:
                                const Icon(Icons.category, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.category, color: Colors.grey),
                      ),
              ),
            ),

            const SizedBox(width: 16),

            // Informations de la catégorie
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (category['description'] != null &&
                      category['description'].toString().isNotEmpty)
                    Text(
                      category['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: category['isActive'] == true
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category['isActive'] == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: category['isActive'] == true
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () => _showAddEditCategoryDialog(category),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  onPressed: () =>
                      _deleteCategory(category['id'], category['name']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
