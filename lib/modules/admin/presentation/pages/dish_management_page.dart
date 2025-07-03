import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class DishManagementPage extends ConsumerStatefulWidget {
  const DishManagementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DishManagementPage> createState() => _DishManagementPageState();
}

class _DishManagementPageState extends ConsumerState<DishManagementPage> {
  List<Map<String, dynamic>> dishes = [];
  List<Map<String, dynamic>> restaurants = [];
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

      // Charger les plats
      final dishesSnapshot =
          await FirebaseFirestore.instance.collection('dishes').get();

      setState(() {
        dishes = dishesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Nom inconnu',
            'description': data['description'] ?? 'Description inconnue',
            'price': data['price']?.toDouble() ?? 0.0,
            'restaurantId': data['restaurantId'] ?? '',
            'restaurantName': data['restaurantName'] ?? 'Restaurant inconnu',
            'category': data['category'] ?? 'Catégorie inconnue',
            'imageUrl': data['imageUrl'] ?? '',
            'isAvailable': data['isAvailable'] ?? true,
            'rating': data['rating']?.toDouble() ?? 0.0,
            'preparationTime': data['preparationTime'] ?? '20-30 min',
          };
        }).toList();
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
              .contains(searchQuery.toLowerCase());

      final matchesRestaurant = selectedRestaurantId == 'all' ||
          dish['restaurantId'] == selectedRestaurantId;

      final matchesCategory =
          selectedCategory == 'all' || dish['category'] == selectedCategory;

      return matchesSearch && matchesRestaurant && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final categories =
        dishes.map((dish) => dish['category'].toString()).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<void> _toggleDishAvailability(
      String dishId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('dishes')
          .doc(dishId)
          .update({'isAvailable': !currentStatus});

      await _loadData();
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

        await _loadData();
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
              // TODO: Navigation vers ajout de plat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité à venir')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un plat...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('Tous les restaurants'),
                          ),
                          ...restaurants.map((restaurant) => DropdownMenuItem(
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
                          fillColor: Colors.white,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('Toutes les catégories'),
                          ),
                          ...categories.map((category) => DropdownMenuItem(
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  'Total',
                  dishes.length.toString(),
                  Icons.fastfood,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Disponibles',
                  dishes.where((d) => d['isAvailable']).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Indisponibles',
                  dishes.where((d) => !d['isAvailable']).length.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des plats
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDishes.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun plat trouvé',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredDishes.length,
                        itemBuilder: (context, index) {
                          final dish = filteredDishes[index];
                          return _buildDishCard(dish);
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              dish['imageUrl'] != null && dish['imageUrl'].isNotEmpty
                  ? NetworkImage(dish['imageUrl'])
                  : null,
          child: dish['imageUrl'] == null || dish['imageUrl'].isEmpty
              ? const Icon(Icons.fastfood, size: 30, color: Colors.grey)
              : null,
        ),
        title: Text(
          dish['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dish['description'],
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF24E1E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${dish['price']} €',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF24E1E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dish['category'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${dish['rating']}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  dish['preparationTime'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Restaurant: ${dish['restaurantName']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: dish['isAvailable'],
              onChanged: (value) =>
                  _toggleDishAvailability(dish['id'], dish['isAvailable']),
              activeColor: const Color(0xFFF24E1E),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Navigation vers édition
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                } else if (value == 'delete') {
                  _deleteDish(dish['id'], dish['name']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
