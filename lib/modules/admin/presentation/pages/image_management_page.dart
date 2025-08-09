import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

@RoutePage()
class ImageManagementPage extends StatefulWidget {
  const ImageManagementPage({Key? key}) : super(key: key);

  @override
  State<ImageManagementPage> createState() => _ImageManagementPageState();
}

class _ImageManagementPageState extends State<ImageManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _dishes = [];
  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger les plats avec images
      final dishesSnapshot = await _firestore.collection('dishes').get();
      final dishes = dishesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'restaurant_id': data['restaurant_id'] ?? '',
          'type': 'plat',
        };
      }).toList();

      // Charger les restaurants avec images
      final restaurantsSnapshot =
          await _firestore.collection('restaurants').get();
      final restaurants = restaurantsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'type': 'restaurant',
        };
      }).toList();

      // Combiner et filtrer les images
      final allImages = [...dishes, ...restaurants]
          .where((item) =>
              item['imageUrl'] != null &&
              item['imageUrl'].toString().isNotEmpty)
          .toList();

      setState(() {
        _images = allImages;
        _dishes = dishes;
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des images: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredImages {
    return _images.where((image) {
      final matchesFilter = _selectedFilter == 'Tous' ||
          image['type'] == _selectedFilter.toLowerCase();
      final matchesSearch = image['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> _uploadImage(String itemId, String itemType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Afficher un indicateur de progression
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Upload vers Firebase Storage
      final fileName =
          '${itemType}_${itemId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('images/$itemType/$fileName');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour dans Firestore
      final collection = itemType == 'plat' ? 'dishes' : 'restaurants';
      await _firestore.collection(collection).doc(itemId).update({
        'imageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // Fermer le dialog de progression
      _loadData(); // Recharger les données

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image mise à jour avec succès')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialog de progression
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _deleteImage(String itemId, String itemType) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette image ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Supprimer l'image dans Firestore
      final collection = itemType == 'plat' ? 'dishes' : 'restaurants';
      await _firestore.collection(collection).doc(itemId).update({
        'imageUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _loadData(); // Recharger les données

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image supprimée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Images'),
        backgroundColor: const Color(0xFFF24E1E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres et recherche
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Barre de recherche
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher une image...',
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
                      const SizedBox(height: 12),
                      // Filtres
                      Row(
                        children: [
                          const Text('Filtrer par: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            items: ['Tous', 'Plat', 'Restaurant'].map((filter) {
                              return DropdownMenuItem(
                                value: filter,
                                child: Text(filter),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFilter = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Statistiques
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard(
                          'Total', _images.length.toString(), Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          'Plats',
                          _images
                              .where((i) => i['type'] == 'plat')
                              .length
                              .toString(),
                          Colors.green),
                      const SizedBox(width: 12),
                      _buildStatCard(
                          'Restaurants',
                          _images
                              .where((i) => i['type'] == 'restaurant')
                              .length
                              .toString(),
                          Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Liste des images
                Expanded(
                  child: _filteredImages.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune image trouvée',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredImages.length,
                          itemBuilder: (context, index) {
                            final image = _filteredImages[index];
                            return _buildImageCard(image);
                          },
                        ),
                ),
              ],
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

  Widget _buildImageCard(Map<String, dynamic> image) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image['imageUrl'] != null &&
                      image['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                      image['imageUrl'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image['name'] ?? 'Sans nom',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: image['type'] == 'plat'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      image['type'] == 'plat' ? 'Plat' : 'Restaurant',
                      style: TextStyle(
                        fontSize: 12,
                        color: image['type'] == 'plat'
                            ? Colors.green
                            : Colors.orange,
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
                  onPressed: () => _uploadImage(image['id'], image['type']),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Modifier l\'image',
                ),
                IconButton(
                  onPressed: () => _deleteImage(image['id'], image['type']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer l\'image',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
