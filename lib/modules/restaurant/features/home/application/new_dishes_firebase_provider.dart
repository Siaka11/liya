import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// État pour les nouveaux plats Firebase
class NewDishesFirebaseState {
  final List<Map<String, dynamic>>? dishes;
  final bool isLoading;
  final String? error;

  NewDishesFirebaseState({
    this.dishes,
    this.isLoading = false,
    this.error,
  });

  NewDishesFirebaseState copyWith({
    List<Map<String, dynamic>>? dishes,
    bool? isLoading,
    String? error,
  }) {
    return NewDishesFirebaseState(
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier pour gérer les nouveaux plats Firebase
class NewDishesFirebaseNotifier extends StateNotifier<NewDishesFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NewDishesFirebaseNotifier() : super(NewDishesFirebaseState());

  Future<void> loadNewDishes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Récupérer tous les plats disponibles, puis filtrer côté client
      final dishesSnapshot = await _firestore
          .collection('dishes')
          .orderBy('createdAt', descending: true)
          .limit(20) // Récupérer plus de plats pour avoir assez après filtrage
          .get();

      final List<Map<String, dynamic>> dishes = [];
     // final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data();

        // Vérifier si le plat est disponible et récent
        final isAvailable =
            dishData['isAvailable'] ?? dishData['is_available'] ?? true;
        final createdAt = dishData['createdAt'];

        if (!isAvailable) continue;

        // Vérifier si le plat a été créé dans les 30 derniers jours
        /*if (createdAt != null) {
          final createdDate =
              createdAt is DateTime ? createdAt : createdAt.toDate();
          if (createdDate.isBefore(thirtyDaysAgo)) continue;
        }*/

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
          // La catégorie peut être stockée comme ID ou comme nom directement
          final categoryId = dishData['categorie'];
          if (categoryId != null) {
            final categoryDoc =
                await _firestore.collection('categories').doc(categoryId).get();

            if (categoryDoc.exists) {
              categoryName = categoryDoc.data()?['name'] ?? categoryId;
            } else {
              // Si le document n'existe pas, utiliser la valeur directement
              categoryName = categoryId;
            }
          }
        } catch (e) {
          print('Erreur lors de la récupération de la catégorie: $e');
          // En cas d'erreur, utiliser la valeur directe
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

      print('Plats trouvés: ${dishes.length}');
      for (final dish in dishes) {
        print(
            'Plat: ${dish['name']} - Restaurant: ${dish['restaurant_name']} - Catégorie: ${dish['categorie']}');
      }

      state = state.copyWith(
        dishes: dishes,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement des nouveaux plats: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des plats: $e',
      );
    }
  }

  void refresh() {
    loadNewDishes();
  }
}

// Provider pour les nouveaux plats Firebase
final newDishesFirebaseProvider =
    StateNotifierProvider<NewDishesFirebaseNotifier, NewDishesFirebaseState>(
        (ref) {
  return NewDishesFirebaseNotifier();
});
