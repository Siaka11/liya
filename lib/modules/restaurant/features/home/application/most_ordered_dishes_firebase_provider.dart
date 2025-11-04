import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/services/dish_popularity_service.dart';

// État pour les plats les plus commandés Firebase
class MostOrderedDishesFirebaseState {
  final List<Map<String, dynamic>>? dishes;
  final bool isLoading;
  final String? error;

  MostOrderedDishesFirebaseState({
    this.dishes,
    this.isLoading = false,
    this.error,
  });

  MostOrderedDishesFirebaseState copyWith({
    List<Map<String, dynamic>>? dishes,
    bool? isLoading,
    String? error,
  }) {
    return MostOrderedDishesFirebaseState(
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier pour gérer les plats les plus commandés Firebase
class MostOrderedDishesFirebaseNotifier
    extends StateNotifier<MostOrderedDishesFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MostOrderedDishesFirebaseNotifier() : super(MostOrderedDishesFirebaseState());

  /// Méthode pour s'assurer que les champs order_count sont initialisés
  Future<void> ensureOrderCountFields() async {
    try {
      print('🔄 Vérification des champs order_count...');

      // Récupérer quelques plats pour vérifier leurs champs
      final snapshot = await _firestore.collection('dishes').limit(5).get();

      bool needsUpdate = false;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        if (!data.containsKey('order_count')) {
          needsUpdate = true;
          break;
        }
      }

      if (needsUpdate) {
        print('⚡ Initialisation des champs order_count manquants...');
        // Appeler le service d'initialisation complet
        await DishPopularityService.initializeAllExistingDishes();
      }
    } catch (e) {
      print('⚠️ Erreur lors de la vérification des champs order_count: $e');
    }
  }

  Future<void> loadMostOrderedDishes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // S'assurer que les champs order_count sont initialisés
      await ensureOrderCountFields();

      // Récupérer les plats les plus commandés basés sur order_count uniquement
      print('🔥 Chargement des plats les plus commandés par order_count...');

      QuerySnapshot dishesSnapshot;
      bool needsManualSort = false;

      try {
        // Essayer d'abord avec le tri par order_count
        dishesSnapshot = await _firestore
            .collection('dishes')
            .orderBy('order_count', descending: true)
            .limit(20)
            .get();
        print('✅ Tri par order_count réussi');
      } catch (e) {
        // Fallback : récupérer tous les plats et trier manuellement
        print('⚠️ Index order_count non disponible, tri manuel: $e');
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

        // Filtrer uniquement les plats qui ont été commandés au moins une fois
        final orderCount = dishData['order_count'] ?? 0;
        if (orderCount == 0) continue;

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
          'order_count': orderCount,
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

        // Limiter à 10 plats maximum si on utilise déjà le tri Firestore
        if (!needsManualSort && dishes.length >= 10) break;
      }

      // Si on a récupéré sans tri par order_count, trier manuellement
      if (needsManualSort) {
        print('📊 Tri manuel par order_count...');
        dishes.sort((a, b) {
          final orderCountA = (a['order_count'] ?? 0) as int;
          final orderCountB = (b['order_count'] ?? 0) as int;
          return orderCountB.compareTo(orderCountA); // Ordre décroissant
        });

        // Limiter à 10 après le tri
        if (dishes.length > 10) {
          dishes.removeRange(10, dishes.length);
        }
      }

      print('🔥 Plats les plus commandés trouvés: ${dishes.length}');
      for (final dish in dishes) {
        print(
            '📊 ${dish['name']} - Commandes: ${dish['order_count']} - Vues: ${dish['view_count']} - Rating: ${dish['rating']} (${dish['rating_count']} avis)');
      }

      state = state.copyWith(
        dishes: dishes,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement des plats les plus commandés: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadMostOrderedDishes();
  }
}

// Provider pour les plats les plus commandés Firebase
final mostOrderedDishesFirebaseProvider = StateNotifierProvider<
    MostOrderedDishesFirebaseNotifier, MostOrderedDishesFirebaseState>((ref) {
  return MostOrderedDishesFirebaseNotifier();
});
