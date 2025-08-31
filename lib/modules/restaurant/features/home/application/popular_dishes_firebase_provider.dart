import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/services/dish_popularity_service.dart';

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

  /// Méthode pour forcer l'actualisation des scores de popularité
  Future<void> refreshPopularityScores() async {
    try {
      print('🔄 Actualisation forcée des scores de popularité...');
      await DishPopularityService.recalculateAllPopularityScores();
      print('✅ Actualisation terminée');
    } catch (e) {
      print('❌ Erreur lors de l\'actualisation: $e');
    }
  }

  /// Méthode pour recalculer avec la formule unifiée
  Future<void> unifyAllPopularityScores() async {
    try {
      print('🔄 Unification de tous les scores de popularité...');
      await DishPopularityService.recalculateAllPopularityScoresUnified();
      print('✅ Unification terminée, rechargement des plats populaires...');
      await loadPopularDishes();
    } catch (e) {
      print('❌ Erreur unification scores: $e');
    }
  }

  /// Méthode pour réinitialiser tous les scores à zéro et recalculer avec la moyenne
  Future<void> resetToAverageScoring() async {
    try {
      print('🔄 Réinitialisation à la moyenne (0-100)...');

      // 1. Remettre toutes les données à zéro
      await DishPopularityService.resetAllPopularityToZero();

      // 2. Recalculer avec la nouvelle formule de moyenne
      await DishPopularityService.recalculateAllPopularityScoresUnified();

      print(
          '✅ Réinitialisation terminée, rechargement des plats populaires...');
      await loadPopularDishes();

      print(
          '📊 Tous les plats utilisent maintenant la moyenne normalisée (0-100)');
    } catch (e) {
      print('❌ Erreur réinitialisation moyenne: $e');
    }
  }

  /// Méthode pour s'assurer que les scores de popularité sont à jour
  Future<void> ensurePopularityScores() async {
    try {
      print('🔄 Vérification des scores de popularité...');

      // Récupérer quelques plats pour vérifier leurs scores
      final snapshot = await _firestore.collection('dishes').limit(5).get();

      bool needsUpdate = false;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('popularity_score') ||
            !data.containsKey('view_count') ||
            !data.containsKey('order_count')) {
          needsUpdate = true;
          break;
        }
      }

      if (needsUpdate) {
        print('⚡ Initialisation des champs de popularité manquants...');
        // Appeler le service d'initialisation complet
        await DishPopularityService.initializeAllExistingDishes();
        // Recalculer les scores après initialisation
        await DishPopularityService.recalculateAllPopularityScores();
      }
    } catch (e) {
      print('⚠️ Erreur lors de la vérification des scores: $e');
    }
  }

  Future<void> loadPopularDishes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // S'assurer que les scores de popularité sont initialisés
      await ensurePopularityScores();

      // Récupérer les plats populaires basés sur le score de popularité
      // Le score prend en compte : order_count, view_count, rating, et récence
      print('🔥 Chargement des plats populaires par score de popularité...');

      QuerySnapshot dishesSnapshot;
      bool needsManualSort = false;

      try {
        // Essayer d'abord avec le tri par popularity_score
        dishesSnapshot = await _firestore
            .collection('dishes')
            .orderBy('popularity_score', descending: true)
            .limit(20)
            .get();
        print('✅ Tri par popularity_score réussi');
      } catch (e) {
        // Fallback : récupérer tous les plats et trier manuellement
        print('⚠️ Index popularity_score non disponible, tri manuel: $e');
        needsManualSort = true;
        dishesSnapshot = await _firestore
            .collection('dishes')
            .limit(50) // Récupérer plus pour avoir le choix
            .get();
      }

      final List<Map<String, dynamic>> dishes = [];

      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data() as Map<String, dynamic>?;
        if (dishData == null) continue;

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
          'order_count': dishData['order_count'] ?? 0,
          'view_count':
              dishData['view_count'] ?? 0, // Ajouter le compteur de vues
          'popularity_score':
              dishData['popularity_score'] ?? 0.0, // Score de popularité
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

        // Limiter à 10 plats maximum si on utilise déjà le tri Firestore
        if (!needsManualSort && dishes.length >= 10) break;
      }

      // Si on a récupéré sans tri par popularity_score, trier manuellement
      if (needsManualSort) {
        print('📊 Tri manuel par popularity_score...');
        dishes.sort((a, b) {
          final scoreA = (a['popularity_score'] ?? 0.0) as double;
          final scoreB = (b['popularity_score'] ?? 0.0) as double;
          return scoreB.compareTo(scoreA); // Ordre décroissant
        });

        // Limiter à 10 après le tri
        if (dishes.length > 10) {
          dishes.removeRange(10, dishes.length);
        }
      }

      print('🔥 Plats populaires trouvés: ${dishes.length}');
      for (final dish in dishes) {
        print(
            '📊 ${dish['name']} - Score: ${dish['popularity_score']} - Vues: ${dish['view_count']} - Commandes: ${dish['order_count']} - Rating: ${dish['rating']} (${dish['rating_count']} avis)');
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
