import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// État pour les restaurants Firebase
class RestaurantsFirebaseState {
  final List<Map<String, dynamic>>? restaurants;
  final bool isLoading;
  final String? error;

  RestaurantsFirebaseState({
    this.restaurants,
    this.isLoading = false,
    this.error,
  });

  RestaurantsFirebaseState copyWith({
    List<Map<String, dynamic>>? restaurants,
    bool? isLoading,
    String? error,
  }) {
    return RestaurantsFirebaseState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier pour gérer les restaurants Firebase
class RestaurantsFirebaseNotifier
    extends StateNotifier<RestaurantsFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RestaurantsFirebaseNotifier() : super(RestaurantsFirebaseState());

  Future<void> loadRestaurants() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔥 Début chargement restaurants Firebase...');

      // Récupérer tous les restaurants actifs
      final restaurantsSnapshot = await _firestore
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      print(
          '🔥 Restaurants trouvés dans Firestore: ${restaurantsSnapshot.docs.length}');

      final List<Map<String, dynamic>> restaurants = [];

      for (final doc in restaurantsSnapshot.docs) {
        final restaurantData = doc.data();
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
          'cover_image': restaurantData['coverImage'] ?? '', // Correction ici
          'logo': restaurantData['logo'] ?? '',
          'address': restaurantData['address'] ?? '',
          'phone': restaurantData['phone'] ?? '',
          'email': restaurantData['email'] ?? '',
          'rating': (restaurantData['rating'] ?? 0.0).toDouble(),
          'rating_count': restaurantData['rating_count'] ?? 0,
          'is_active': isActive, // Correction ici
          'is_open': restaurantData['is_open'] ?? true,
          'opening_hours':
              restaurantData['openingHours'] ?? {}, // Correction ici
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
          'created_at': restaurantData['createdAt'], // Correction ici
          'updated_at': restaurantData['updatedAt'],
        });
      }

      print('Restaurants trouvés: ${restaurants.length}');
      for (final restaurant in restaurants) {
        print(
            'Restaurant: ${restaurant['name']} - Rating: ${restaurant['rating']} - Plats: ${restaurant['dishes_count']}');
      }

      state = state.copyWith(
        restaurants: restaurants,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement des restaurants: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des restaurants: $e',
      );
    }
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
