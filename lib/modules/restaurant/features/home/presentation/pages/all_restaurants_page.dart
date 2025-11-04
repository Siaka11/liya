import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import '../../application/restaurants_firebase_provider.dart';
import '../widget/restaurant_firebase_card.dart';

@RoutePage()
class AllRestaurantsPage extends ConsumerStatefulWidget {
  const AllRestaurantsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AllRestaurantsPage> createState() => _AllRestaurantsPageState();
}

class _AllRestaurantsPageState extends ConsumerState<AllRestaurantsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredRestaurants = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRestaurants(List<Map<String, dynamic>> restaurants) {
    if (_searchQuery.isEmpty) {
      _filteredRestaurants = restaurants;
    } else {
      _filteredRestaurants = restaurants.where((restaurant) {
        final name = (restaurant['name'] ?? '').toString().toLowerCase();
        final description =
            (restaurant['description'] ?? '').toString().toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return name.contains(searchLower) || description.contains(searchLower);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsState = ref.watch(restaurantsFirebaseProvider);
    final restaurantsController =
        ref.read(restaurantsFirebaseProvider.notifier);

    // Charger les restaurants si pas encore chargés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantsState.restaurants == null && !restaurantsState.isLoading) {
        restaurantsController.loadRestaurants();
      }
    });

    // Filtrer les restaurants quand la liste ou la recherche change
    if (restaurantsState.restaurants != null) {
      _filterRestaurants(restaurantsState.restaurants!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tous les restaurants",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Dropdown pour le tri
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<RestaurantSortOption>(
              value: restaurantsState.sortOption,
              underline: Container(),
              icon: const Icon(Icons.sort, size: 16),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: RestaurantSortOption.values.map((option) {
                return DropdownMenuItem<RestaurantSortOption>(
                  value: option,
                  child: Text(
                    option.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (RestaurantSortOption? newOption) {
                if (newOption != null) {
                  restaurantsController.changeSortOption(newOption);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Champ de recherche
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un restaurant...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Liste des restaurants
          Expanded(
            child: restaurantsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : restaurantsState.error != null
                    ? Center(child: Text('Erreur: ${restaurantsState.error}'))
                    : _filteredRestaurants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Aucun restaurant trouvé pour "$_searchQuery"'
                                      : 'Aucun restaurant disponible',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    child: const Text('Effacer la recherche'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _filteredRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = _filteredRestaurants[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: RestaurantFirebaseCard(
                                  width: MediaQuery.of(context).size.width,
                                  restaurant: restaurant,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RestaurantDetailPage(
                                          coverImage:
                                              restaurant['cover_image'] ?? '',
                                          id: restaurant['id'],
                                          name: restaurant['name'],
                                          description:
                                              restaurant['description'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
