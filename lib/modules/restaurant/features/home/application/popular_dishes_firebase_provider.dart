import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// État pour les plats populaires Firebase
class PopularDishesFirebaseState {
  final List<Map<String, dynamic>>? dishes;
  final bool isLoading;
  final String? error;

  PopularDishesFirebaseState({
    this.dishes,
    this.isLoading = false,
    this.error,
  });

  PopularDishesFirebaseState copyWith({
    List<Map<String, dynamic>>? dishes,
    bool? isLoading,
    String? error,
  }) {
    return PopularDishesFirebaseState(
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier pour gérer les plats populaires Firebase
class PopularDishesFirebaseNotifier
    extends StateNotifier<PopularDishesFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PopularDishesFirebaseNotifier() : super(PopularDishesFirebaseState());

  Future<void> loadPopularDishes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Récupérer les plats populaires basés sur les critères suivants :
      // 1. Plats disponibles
      // 2. Trier par rating puis par date de création
      // TODO: Quand order_count sera disponible, changer pour :
      // .orderBy('order_count', descending: true)
      // Option 1: Sans orderBy pour éviter l'index composite
      final dishesSnapshot = await _firestore
          .collection('dishes')
          .orderBy('createdAt', descending: false)
          .limit(20)
          .get();

      // Option 2: Avec orderBy mais sans where (si vous voulez garder le tri)
      // final dishesSnapshot = await _firestore
      //     .collection('dishes')
      //     .orderBy('createdAt', descending: false)
      //     .limit(20)
      //     .get();

      final List<Map<String, dynamic>> dishes = [];

      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data();

        // Vérifier si le plat est disponible
        final isAvailable = dishData['isAvailable'] ?? true;
        if (!isAvailable) continue;

        // Pour l'instant, utiliser tous les plats disponibles
        // Plus tard, on pourra filtrer par rating ou order_count
        final rating = (dishData['rating'] ?? 0.0).toDouble();

        // Récupérer les informations du restaurant
        String restaurantName = 'Restaurant inconnu';
        try {
          final restaurantDoc = await _firestore
              .collection('restaurants')
              .doc(dishData['restaurant_id'])
              .get();

          if (restaurantDoc.exists) {
            restaurantName =
                restaurantDoc.data()?['name'] ?? 'Restaurant inconnu';
          }
        } catch (e) {
          print('Erreur lors de la récupération du restaurant: $e');
        }

        // Récupérer les informations de la catégorie
        String categoryName = 'Catégorie inconnue';
        try {
          final categoryId = dishData['categorie'];
          if (categoryId != null) {
            final categoryDoc =
                await _firestore.collection('categories').doc(categoryId).get();

            if (categoryDoc.exists) {
              categoryName = categoryDoc.data()?['name'] ?? categoryId;
            } else {
              categoryName = categoryId;
            }
          }
        } catch (e) {
          print('Erreur lors de la récupération de la catégorie: $e');
          categoryName = dishData['categorie'] ?? 'Catégorie inconnue';
        }

        // Calculer le prix final avec les promotions
        double finalPrice = (dishData['price'] ?? 0.0).toDouble();
        double originalPrice =
            (dishData['original_price'] ?? finalPrice).toDouble();
        bool isOnSale = dishData['is_on_sale'] ?? false;
        double discountPercentage = 0.0;

        if (isOnSale && originalPrice > finalPrice) {
          discountPercentage =
              ((originalPrice - finalPrice) / originalPrice) * 100;
        }

        dishes.add({
          'id': doc.id,
          'name': dishData['name'] ?? 'Nom inconnu',
          'description': dishData['description'] ?? '',
          'price': finalPrice,
          'original_price': originalPrice,
          'is_on_sale': isOnSale,
          'discount_percentage': discountPercentage,
          'image_url': dishData['image_url'] ?? '',
          'restaurant_id': dishData['restaurant_id'] ?? '',
          'restaurant_name': restaurantName,
          'categorie': categoryName,
          'preparation_time': dishData['preparation_time'] ?? 30,
          'rating': rating,
          'rating_count': dishData['rating_count'] ?? 0,
          'order_count':
              dishData['order_count'] ?? 0, // Ajouter le compteur de commandes
          'is_vegetarian': dishData['is_vegetarian'] ?? false,
          'is_vegan': dishData['is_vegan'] ?? false,
          'is_gluten_free': dishData['is_gluten_free'] ?? false,
          'allergens': dishData['allergens'] ?? [],
          'calories': dishData['calories'],
          'spice_level': dishData['spice_level'],
          'tags': dishData['tags'] ?? [],
          'createdAt': dishData['createdAt'],
          'updatedAt': dishData['updatedAt'],
        });

        // Limiter à 10 plats maximum
        if (dishes.length >= 10) break;
      }

      print('Plats populaires trouvés: ${dishes.length}');
      for (final dish in dishes) {
        print(
            'Plat populaire: ${dish['name']} - Rating: ${dish['rating']} - Prix: ${dish['price']} - Restaurant: ${dish['restaurant_name']}');
      }

      state = state.copyWith(
        dishes: dishes,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement des plats populaires: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des plats populaires: $e',
      );
    }
  }

  void refresh() {
    loadPopularDishes();
  }
}

// Provider pour les plats populaires Firebase
final popularDishesFirebaseProvider = StateNotifierProvider<
    PopularDishesFirebaseNotifier, PopularDishesFirebaseState>((ref) {
  return PopularDishesFirebaseNotifier();
});

// Notifier spécialisé pour tous les plats
class AllDishesFirebaseNotifier
    extends StateNotifier<PopularDishesFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AllDishesFirebaseNotifier() : super(PopularDishesFirebaseState());

  Future<void> loadAllDishes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Récupérer tous les plats disponibles (sans limite)
      final dishesSnapshot = await _firestore
          .collection('dishes')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> dishes = [];

      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data();

        // Vérifier si le plat est disponible
        final isAvailable = dishData['isAvailable'] ?? true;
        if (!isAvailable) continue;

        // Récupérer les informations du restaurant
        String restaurantName = 'Restaurant inconnu';
        try {
          final restaurantDoc = await _firestore
              .collection('restaurants')
              .doc(dishData['restaurant_id'])
              .get();

          if (restaurantDoc.exists) {
            restaurantName =
                restaurantDoc.data()?['name'] ?? 'Restaurant inconnu';
          }
        } catch (e) {
          print('Erreur lors de la récupération du restaurant: $e');
        }

        // Récupérer les informations de la catégorie
        String categoryName = 'Catégorie inconnue';
        try {
          final categoryId = dishData['categorie'];
          if (categoryId != null) {
            final categoryDoc =
                await _firestore.collection('categories').doc(categoryId).get();

            if (categoryDoc.exists) {
              categoryName = categoryDoc.data()?['name'] ?? categoryId;
            } else {
              categoryName = categoryId;
            }
          }
        } catch (e) {
          print('Erreur lors de la récupération de la catégorie: $e');
          categoryName = dishData['categorie'] ?? 'Catégorie inconnue';
        }

        // Calculer le prix final avec les promotions
        double finalPrice = (dishData['price'] ?? 0.0).toDouble();
        double originalPrice =
            (dishData['original_price'] ?? finalPrice).toDouble();
        bool isOnSale = dishData['is_on_sale'] ?? false;
        double discountPercentage = 0.0;

        if (isOnSale && originalPrice > finalPrice) {
          discountPercentage =
              ((originalPrice - finalPrice) / originalPrice) * 100;
        }

        dishes.add({
          'id': doc.id,
          'name': dishData['name'] ?? 'Nom inconnu',
          'description': dishData['description'] ?? '',
          'price': finalPrice,
          'original_price': originalPrice,
          'is_on_sale': isOnSale,
          'discount_percentage': discountPercentage,
          'image_url': dishData['image_url'] ?? '',
          'restaurant_id': dishData['restaurant_id'] ?? '',
          'restaurant_name': restaurantName,
          'categorie': categoryName,
          'preparation_time': dishData['preparation_time'] ?? 30,
          'rating': (dishData['rating'] ?? 0.0).toDouble(),
          'rating_count': dishData['rating_count'] ?? 0,
          'order_count': dishData['order_count'] ?? 0,
          'view_count': dishData['view_count'] ?? 0,
          'popularity_score': dishData['popularity_score'] ?? 0.0,
          'is_vegetarian': dishData['is_vegetarian'] ?? false,
          'is_vegan': dishData['is_vegan'] ?? false,
          'is_gluten_free': dishData['is_gluten_free'] ?? false,
          'allergens': dishData['allergens'] ?? [],
          'calories': dishData['calories'],
          'spice_level': dishData['spice_level'],
          'tags': dishData['tags'] ?? [],
          'createdAt': dishData['createdAt'],
          'updatedAt': dishData['updatedAt'],
        });
      }

      print('Tous les plats trouvés: ${dishes.length}');

      state = state.copyWith(
        dishes: dishes,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement de tous les plats: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement de tous les plats: $e',
      );
    }
  }

  void refresh() {
    loadAllDishes();
  }
}

// Provider pour tous les plats
final allDishesFirebaseProvider = StateNotifierProvider<
    AllDishesFirebaseNotifier, PopularDishesFirebaseState>((ref) {
  return AllDishesFirebaseNotifier();
});
