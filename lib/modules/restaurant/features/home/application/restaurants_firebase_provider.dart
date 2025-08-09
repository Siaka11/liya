import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum pour les options de tri des restaurants
enum RestaurantSortOption {
  newest('Plus récents', 'createdAt', true),
  oldest('Plus anciens', 'createdAt', false),
  nameAZ('Nom A-Z', 'name', false),
  nameZA('Nom Z-A', 'name', true),
  dishCountHighest('Plus de plats', 'dishes_count', true),
  dishCountLowest('Moins de plats', 'dishes_count', false);

  const RestaurantSortOption(this.label, this.field, this.descending);
  final String label;
  final String field;
  final bool descending;
}

// État pour les restaurants Firebase
class RestaurantsFirebaseState {
  final List<Map<String, dynamic>>? restaurants;
  final bool isLoading;
  final String? error;
  final RestaurantSortOption sortOption;

  RestaurantsFirebaseState({
    this.restaurants,
    this.isLoading = false,
    this.error,
    this.sortOption = RestaurantSortOption.newest,
  });

  RestaurantsFirebaseState copyWith({
    List<Map<String, dynamic>>? restaurants,
    bool? isLoading,
    String? error,
    RestaurantSortOption? sortOption,
  }) {
    return RestaurantsFirebaseState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

// Notifier pour gérer les restaurants Firebase
class RestaurantsFirebaseNotifier
    extends StateNotifier<RestaurantsFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RestaurantsFirebaseNotifier() : super(RestaurantsFirebaseState());

  Future<void> loadRestaurants([RestaurantSortOption? sortOption]) async {
    final selectedSortOption = sortOption ?? state.sortOption;
    state = state.copyWith(
        isLoading: true, error: null, sortOption: selectedSortOption);

    try {
      print('🔥 Début chargement restaurants Firebase...');
      print('🔥 Tri sélectionné: ${selectedSortOption.label}');

      // Récupérer tous les restaurants actifs (sans orderBy pour l'instant)
      Query query = _firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .limit(20);

      // Appliquer le tri si c'est un champ Firestore standard
      if (selectedSortOption.field == 'createdAt' ||
          selectedSortOption.field == 'name' ||
          selectedSortOption.field == 'rating') {
        query = query.orderBy(selectedSortOption.field,
            descending: selectedSortOption.descending);
      }

      final restaurantsSnapshot = await query.get();

      print(
          '🔥 Restaurants trouvés dans Firestore: ${restaurantsSnapshot.docs.length}');

      final List<Map<String, dynamic>> restaurants = [];

      for (final doc in restaurantsSnapshot.docs) {
        final restaurantData = doc.data() as Map<String, dynamic>;
        print(
            '🔥 Restaurant trouvé: ${doc.id} - ${restaurantData['name']} - isActive: ${restaurantData['isActive']}');

        // Vérifier si le restaurant est actif
        final isActive = restaurantData['isActive'] ?? true;
        if (!isActive) {
          print('🔥 Restaurant ${doc.id} non actif, ignoré');
          continue;
        }

        // Récupérer le nombre de plats disponibles pour ce restaurant
        int dishesCount = 0;
        try {
          final dishesSnapshot = await _firestore
              .collection('dishes')
              .where('restaurant_id', isEqualTo: doc.id)
              .where('isAvailable', isEqualTo: true)
              .get();
          dishesCount = dishesSnapshot.docs.length;
        } catch (e) {
          print(
              'Erreur lors du comptage des plats pour le restaurant ${doc.id}: $e');
        }

        // Récupérer les catégories disponibles
        List<String> categories = [];
        try {
          final categoriesSnapshot = await _firestore
              .collection('dishes')
              .where('restaurant_id', isEqualTo: doc.id)
              .where('isAvailable', isEqualTo: true)
              .get();

          final Set<String> uniqueCategories = {};
          for (final dishDoc in categoriesSnapshot.docs) {
            final dishData = dishDoc.data();
            final category = dishData['categorie'];
            if (category != null) {
              uniqueCategories.add(category.toString());
            }
          }
          categories = uniqueCategories.toList();
        } catch (e) {
          print(
              'Erreur lors de la récupération des catégories pour le restaurant ${doc.id}: $e');
        }

        // Calculer le temps de livraison moyen
        int averageDeliveryTime = restaurantData['average_delivery_time'] ?? 30;

        // Calculer le prix moyen des plats
        double averagePrice = 0.0;
        try {
          final dishesSnapshot = await _firestore
              .collection('dishes')
              .where('restaurant_id', isEqualTo: doc.id)
              .where('isAvailable', isEqualTo: true)
              .get();

          if (dishesSnapshot.docs.isNotEmpty) {
            double totalPrice = 0.0;
            int validPrices = 0;

            for (final dishDoc in dishesSnapshot.docs) {
              final dishData = dishDoc.data();
              final price = dishData['price'];
              if (price != null && price > 0) {
                totalPrice += price.toDouble();
                validPrices++;
              }
            }

            if (validPrices > 0) {
              averagePrice = totalPrice / validPrices;
            }
          }
        } catch (e) {
          print(
              'Erreur lors du calcul du prix moyen pour le restaurant ${doc.id}: $e');
        }

        restaurants.add({
          'id': doc.id,
          'name': restaurantData['name'] ?? 'Restaurant inconnu',
          'description': restaurantData['description'] ?? '',
          'cover_image': restaurantData['coverImage'] ?? '',
          'logo': restaurantData['logo'] ?? '',
          'address': restaurantData['address'] ?? '',
          'phone': restaurantData['phone'] ?? '',
          'email': restaurantData['email'] ?? '',
          'rating': (restaurantData['rating'] ?? 0.0).toDouble(),
          'rating_count': restaurantData['rating_count'] ?? 0,
          'is_active': isActive,
          'is_open': restaurantData['is_open'] ?? true,
          'opening_hours': restaurantData['openingHours'] ?? {},
          'cuisine_type': restaurantData['cuisine_type'] ?? 'Cuisine variée',
          'price_range': restaurantData['price_range'] ?? 'Modéré',
          'average_delivery_time': averageDeliveryTime,
          'average_price': averagePrice,
          'dishes_count': dishesCount,
          'categories': categories,
          'delivery_fee': restaurantData['delivery_fee'] ?? 0.0,
          'minimum_order': restaurantData['minimum_order'] ?? 0.0,
          'latitude': restaurantData['latitude'],
          'longitude': restaurantData['longitude'],
          'created_at': restaurantData['createdAt'],
          'updated_at': restaurantData['updatedAt'],
        });
      }

      // Appliquer le tri côté client pour les champs calculés
      if (selectedSortOption.field == 'dishes_count') {
        restaurants.sort((a, b) {
          final aCount = a['dishes_count'] as int;
          final bCount = b['dishes_count'] as int;
          return selectedSortOption.descending
              ? bCount.compareTo(aCount)
              : aCount.compareTo(bCount);
        });
      }

      print('Restaurants trouvés: ${restaurants.length}');
      print('🔥 Tri appliqué: ${selectedSortOption.label}');
      for (final restaurant in restaurants.take(3)) {
        print(
            'Restaurant: ${restaurant['name']} - Rating: ${restaurant['rating']} - Plats: ${restaurant['dishes_count']}');
      }

      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
        sortOption: selectedSortOption,
      );
    } catch (e) {
      print('Erreur lors du chargement des restaurants: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des restaurants: $e',
      );
    }
  }

  void changeSortOption(RestaurantSortOption sortOption) {
    loadRestaurants(sortOption);
  }

  void refresh() {
    loadRestaurants();
  }
}

// Provider pour les restaurants Firebase
final restaurantsFirebaseProvider = StateNotifierProvider<
    RestaurantsFirebaseNotifier, RestaurantsFirebaseState>((ref) {
  return RestaurantsFirebaseNotifier();
});
