import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../routes/app_router.gr.dart';
import 'add_dish_page.dart';

@RoutePage()
class DishManagementPage extends ConsumerStatefulWidget {
  const DishManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DishManagementPage> createState() => _DishManagementPageState();
}

class _DishManagementPageState extends ConsumerState<DishManagementPage> {
  List<Map<String, dynamic>> dishes = [];
  List<Map<String, dynamic>> restaurants = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedRestaurantId = 'all';
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Charger les restaurants
      final restaurantsSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      restaurants = restaurantsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Nom inconnu',
        };
      }).toList();

      // Charger les catégories depuis Firestore
      final categoriesSnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      categories = categoriesSnapshot.docs
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

      // Charger les plats
      final dishesSnapshot =
          await FirebaseFirestore.instance.collection('dishes').get();

      dishes = dishesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Nom inconnu',
          'description': data['description'] ?? 'Description inconnue',
          'price': data['price']?.toDouble() ?? 0.0,
          'restaurant_id': data['restaurant_id'] ?? '',
          'restaurantName': data['restaurantName'] ?? 'Restaurant inconnu',
          'categorie': data['categorie'] ?? 'Catégorie inconnue',
          'image_url': data['image_url'] ?? '',
          'isAvailable': data['isAvailable'] ?? true,
          'rating': data['rating']?.toDouble() ?? 0.0,
          'preparation_time': data['preparation_time'] ?? '20-30 min',
        };
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredDishes {
    return dishes.where((dish) {
      final matchesSearch = searchQuery.isEmpty ||
          dish['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dish['description']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dish['restaurantName']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesRestaurant = selectedRestaurantId == 'all' ||
          dish['restaurant_id'] == selectedRestaurantId;

      final matchesCategory =
          selectedCategory == 'all' || dish['categorie'] == selectedCategory;

      return matchesSearch && matchesRestaurant && matchesCategory;
    }).toList();
  }

  List<String> get categoryNames {
    return categories.map((cat) => cat['name'].toString()).toList();
  }

  Future<void> _toggleDishAvailability(
      String dishId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('dishes')
          .doc(dishId)
          .update({'isAvailable': !currentStatus});

      // Mettre à jour localement sans recharger tout
      setState(() {
        final dishIndex = dishes.indexWhere((d) => d['id'] == dishId);
        if (dishIndex != -1) {
          dishes[dishIndex]['isAvailable'] = !currentStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disponibilité du plat mise à jour'),
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
    }
  }

  Future<void> _deleteDish(String dishId, String dishName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer le plat "$dishName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('dishes')
            .doc(dishId)
            .delete();

        // Mettre à jour localement sans recharger tout
        setState(() {
          dishes.removeWhere((d) => d['id'] == dishId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plat supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        title: const Text(
          'Gestion des Plats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              AutoRouter.of(context).push(const AddDishRoute());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AutoRouter.of(context).push(const AddDishRoute());
        },
        backgroundColor: const Color(0xFFF24E1E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Barre de recherche
                      TextField(
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText:
                              'Rechercher un plat, restaurant ou description...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filtres par restaurant et catégorie
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedRestaurantId,
                              decoration: InputDecoration(
                                labelText: 'Restaurant',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Tous les restaurants'),
                                ),
                                ...restaurants
                                    .map((restaurant) => DropdownMenuItem(
                                          value: restaurant['id'],
                                          child: Text(restaurant['name']),
                                        )),
                              ],
                              onChanged: (value) =>
                                  setState(() => selectedRestaurantId = value!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Catégorie',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Toutes les catégories'),
                                ),
                                ...categoryNames
                                    .map((category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        )),
                              ],
                              onChanged: (value) =>
                                  setState(() => selectedCategory = value!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Statistiques
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total Plats',
                        '${dishes.length}',
                        Icons.restaurant_menu,
                        const Color(0xFFF24E1E),
                      ),
                      _buildStatCard(
                        'Disponibles',
                        '${dishes.where((d) => d['isAvailable'] == true).length}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Catégories',
                        '${categoryNames.length}',
                        Icons.category,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),

                // Liste des plats
                Expanded(
                  child: filteredDishes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isNotEmpty ||
                                        selectedRestaurantId != 'all' ||
                                        selectedCategory != 'all'
                                    ? 'Aucun plat trouvé avec ces critères'
                                    : 'Aucun plat disponible',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajoutez votre premier plat !',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredDishes.length,
                          itemBuilder: (context, index) {
                            return _buildDishCard(filteredDishes[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDishCard(Map<String, dynamic> dish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: dish['image_url'] != null && dish['image_url'].isNotEmpty
                ? Image.network(dish['image_url'],
                    width: 100, height: 180, fit: BoxFit.cover)
                : Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood,
                        size: 40, color: Colors.grey),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              dish['isAvailable'] ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dish['isAvailable'] ? 'actif' : 'inactif',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dish['description'],
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.restaurant,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dish['restaurantName'],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(dish['categorie'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(dish['preparation_time'],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 16),
                      const Icon(Icons.price_change,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${dish['price']} CFA',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Switch(
                value: dish['isAvailable'],
                onChanged: (v) =>
                    _toggleDishAvailability(dish['id'], dish['isAvailable']),
                activeColor: Colors.green,
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'details') {
                    _showDishDetails(dish);
                  } else if (value == 'edit') {
                    final result = await AutoRouter.of(context).push(
                      EditDishRoute(
                        dishId: dish['id'],
                        dishData: dish,
                      ),
                    );

                    // Recharger les données si le plat a été modifié
                    if (result == true) {
                      await _loadData();
                    }
                  } else if (value == 'edit_image') {
                    _editDishImage(dish);
                  } else if (value == 'delete') {
                    _deleteDish(dish['id'], dish['name']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20),
                        SizedBox(width: 8),
                        Text('Détails')
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Modifier')
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit_image',
                    child: Row(
                      children: [
                        Icon(Icons.image, size: 20, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Modifier l\'image',
                            style: TextStyle(color: Colors.blue))
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDishDetails(Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dish['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dish['image_url'] != null && dish['image_url'].isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(dish['image_url']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('Description: ${dish['description']}'),
            const SizedBox(height: 8),
            Text('Prix: ${dish['price']} €'),
            const SizedBox(height: 8),
            Text('Catégorie: ${dish['categorie']}'),
            const SizedBox(height: 8),
            Text('Restaurant: ${dish['restaurantName']}'),
            const SizedBox(height: 8),
            Text('Temps de préparation: ${dish['preparation_time']}'),
            const SizedBox(height: 8),
            Text('Note: ${dish['rating']}'),
            const SizedBox(height: 8),
            Text(
                'Statut: ${dish['isAvailable'] ? 'Disponible' : 'Indisponible'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _editDishImage(Map<String, dynamic> dish) async {
    final ImagePicker picker = ImagePicker();

    // Afficher un dialog pour choisir la source de l'image
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'image'),
        content: const Text('Choisissez la source de l\'image'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galerie'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Appareil photo'),
          ),
        ],
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
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
          'dish_${dish['id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('dishes/$fileName');
      final uploadTask = ref.putFile(File(image.path));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Mettre à jour dans Firestore
      await FirebaseFirestore.instance
          .collection('dishes')
          .doc(dish['id'])
          .update({
        'image_url': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour localement
      setState(() {
        final dishIndex = dishes.indexWhere((d) => d['id'] == dish['id']);
        if (dishIndex != -1) {
          dishes[dishIndex]['image_url'] = downloadUrl;
        }
      });

      Navigator.of(context).pop(); // Fermer le dialog de progression

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fermer le dialog de progression
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour de l\'image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
