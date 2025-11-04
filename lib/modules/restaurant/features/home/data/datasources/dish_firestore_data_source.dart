import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish_model.dart';

class DishFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupérer tous les plats d'un restaurant spécifique
  Future<List<DishModel>> getDishesByRestaurant(String restaurantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('dishes')
          .where('restaurant_id', isEqualTo: restaurantId)
          .where('isAvailable', isEqualTo: true)
          .orderBy('popularity_score', descending: true)
          .get();

      List<DishModel> dishes = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        try {
          final dish = DishModel(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] as num?)?.toString() ?? '0',
            imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
            category: data['categorie'] ?? data['category'] ?? '',
            restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
            preparationTime:
                data['preparation_time'] ?? data['preparationTime'] ?? '',
            isAvailable: data['isAvailable'] ?? data['is_available'] ?? true,
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            ratingCount: data['rating_count'] ?? data['ratingCount'] ?? 0,
            orderCount: data['order_count'] ?? data['orderCount'] ?? 0,
            viewCount: data['view_count'] ?? data['viewCount'] ?? 0,
            popularityScore:
                (data['popularity_score'] as num?)?.toDouble() ?? 0.0,
            lastOrdered: data['last_ordered'] != null
                ? (data['last_ordered'] as Timestamp).toDate()
                : null,
            lastViewed: data['last_viewed'] != null
                ? (data['last_viewed'] as Timestamp).toDate()
                : null,
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : null,
            updatedAt: data['updatedAt'] != null
                ? (data['updatedAt'] as Timestamp).toDate()
                : null,
            sodas: data['sodas'] ?? 0,
            supplements: data['supplements'] ?? [],
            allergens: data['allergens'] ?? [],
            nutritionalInfo: data['nutritionalInfo'] ?? {},
            tags: data['tags'] ?? [],
            isVegetarian: data['isVegetarian'] ?? false,
            isVegan: data['isVegan'] ?? false,
            isGlutenFree: data['isGlutenFree'] ?? false,
            isSpicy: data['isSpicy'] ?? false,
            calories: data['calories'] ?? 0,
            protein: data['protein'] ?? 0.0,
            carbs: data['carbs'] ?? 0.0,
            fat: data['fat'] ?? 0.0,
          );

          dishes.add(dish);
        } catch (e) {
          print('❌ Erreur création DishModel pour ${doc.id}: $e');
          // Continuer avec le plat suivant
        }
      }

      return dishes;
    } catch (e) {
      print('❌ Erreur récupération plats Firestore: $e');
      return [];
    }
  }

  /// Récupérer tous les plats disponibles
  Future<List<DishModel>> getAllDishes() async {
    try {
      final querySnapshot = await _firestore
          .collection('dishes')
          .where('isAvailable', isEqualTo: true)
          .orderBy('popularity_score', descending: true)
          .get();

      List<DishModel> dishes = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        try {
          final dish = DishModel(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] as num?)?.toString() ?? '0',
            imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
            category: data['categorie'] ?? data['category'] ?? '',
            restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
            preparationTime:
                data['preparation_time'] ?? data['preparationTime'] ?? '',
            isAvailable: data['isAvailable'] ?? data['is_available'] ?? true,
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            ratingCount: data['rating_count'] ?? data['ratingCount'] ?? 0,
            orderCount: data['order_count'] ?? data['orderCount'] ?? 0,
            viewCount: data['view_count'] ?? data['viewCount'] ?? 0,
            popularityScore:
                (data['popularity_score'] as num?)?.toDouble() ?? 0.0,
            lastOrdered: data['last_ordered'] != null
                ? (data['last_ordered'] as Timestamp).toDate()
                : null,
            lastViewed: data['last_viewed'] != null
                ? (data['last_viewed'] as Timestamp).toDate()
                : null,
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : null,
            updatedAt: data['updatedAt'] != null
                ? (data['updatedAt'] as Timestamp).toDate()
                : null,
            sodas: data['sodas'] ?? 0,
            supplements: data['supplements'] ?? [],
            allergens: data['allergens'] ?? [],
            nutritionalInfo: data['nutritionalInfo'] ?? {},
            tags: data['tags'] ?? [],
            isVegetarian: data['isVegetarian'] ?? false,
            isVegan: data['isVegan'] ?? false,
            isGlutenFree: data['isGlutenFree'] ?? false,
            isSpicy: data['isSpicy'] ?? false,
            calories: data['calories'] ?? 0,
            protein: data['protein'] ?? 0.0,
            carbs: data['carbs'] ?? 0.0,
            fat: data['fat'] ?? 0.0,
          );

          dishes.add(dish);
        } catch (e) {
          print('❌ Erreur création DishModel pour ${doc.id}: $e');
          // Continuer avec le plat suivant
        }
      }

      return dishes;
    } catch (e) {
      print('❌ Erreur récupération tous plats Firestore: $e');
      return [];
    }
  }

  /// Récupérer les plats par catégorie
  Future<List<DishModel>> getDishesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('dishes')
          .where('categorie', isEqualTo: category)
          .where('isAvailable', isEqualTo: true)
          .orderBy('popularity_score', descending: true)
          .get();

      List<DishModel> dishes = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        try {
          final dish = DishModel(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] as num?)?.toString() ?? '0',
            imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
            category: data['categorie'] ?? data['category'] ?? '',
            restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
            preparationTime:
                data['preparation_time'] ?? data['preparationTime'] ?? '',
            isAvailable: data['isAvailable'] ?? data['is_available'] ?? true,
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            ratingCount: data['rating_count'] ?? data['ratingCount'] ?? 0,
            orderCount: data['order_count'] ?? data['orderCount'] ?? 0,
            viewCount: data['view_count'] ?? data['viewCount'] ?? 0,
            popularityScore:
                (data['popularity_score'] as num?)?.toDouble() ?? 0.0,
            lastOrdered: data['last_ordered'] != null
                ? (data['last_ordered'] as Timestamp).toDate()
                : null,
            lastViewed: data['last_viewed'] != null
                ? (data['last_viewed'] as Timestamp).toDate()
                : null,
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : null,
            updatedAt: data['updatedAt'] != null
                ? (data['updatedAt'] as Timestamp).toDate()
                : null,
            sodas: data['sodas'] ?? 0,
            supplements: data['supplements'] ?? [],
            allergens: data['allergens'] ?? [],
            nutritionalInfo: data['nutritionalInfo'] ?? {},
            tags: data['tags'] ?? [],
            isVegetarian: data['isVegetarian'] ?? false,
            isVegan: data['isVegan'] ?? false,
            isGlutenFree: data['isGlutenFree'] ?? false,
            isSpicy: data['isSpicy'] ?? false,
            calories: data['calories'] ?? 0,
            protein: data['protein'] ?? 0.0,
            carbs: data['carbs'] ?? 0.0,
            fat: data['fat'] ?? 0.0,
          );

          dishes.add(dish);
        } catch (e) {
          print('❌ Erreur création DishModel pour ${doc.id}: $e');
          // Continuer avec le plat suivant
        }
      }

      return dishes;
    } catch (e) {
      print('❌ Erreur récupération plats par catégorie Firestore: $e');
      return [];
    }
  }

  /// Recherche de plats
  Future<List<DishModel>> searchDishes(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final searchQuery = query.toLowerCase().trim();
      final querySnapshot = await _firestore
          .collection('dishes')
          .where('isAvailable', isEqualTo: true)
          .get();

      List<DishModel> dishes = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        final description =
            (data['description'] as String?)?.toLowerCase() ?? '';
        final category = (data['categorie'] as String?)?.toLowerCase() ?? '';

        if (name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            category.contains(searchQuery)) {
          try {
            final dish = DishModel(
              id: doc.id,
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] as num?)?.toString() ?? '0',
              imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
              category: data['categorie'] ?? data['category'] ?? '',
              restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
              preparationTime:
                  data['preparation_time'] ?? data['preparationTime'] ?? '',
              isAvailable: data['isAvailable'] ?? data['is_available'] ?? true,
              rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
              ratingCount: data['rating_count'] ?? data['ratingCount'] ?? 0,
              orderCount: data['order_count'] ?? data['orderCount'] ?? 0,
              viewCount: data['view_count'] ?? data['viewCount'] ?? 0,
              popularityScore:
                  (data['popularity_score'] as num?)?.toDouble() ?? 0.0,
              lastOrdered: data['last_ordered'] != null
                  ? (data['last_ordered'] as Timestamp).toDate()
                  : null,
              lastViewed: data['last_viewed'] != null
                  ? (data['last_viewed'] as Timestamp).toDate()
                  : null,
              createdAt: data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null,
              updatedAt: data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : null,
              sodas: data['sodas'] ?? 0,
              supplements: data['supplements'] ?? [],
              allergens: data['allergens'] ?? [],
              nutritionalInfo: data['nutritionalInfo'] ?? {},
              tags: data['tags'] ?? [],
              isVegetarian: data['isVegetarian'] ?? false,
              isVegan: data['isVegan'] ?? false,
              isGlutenFree: data['isGlutenFree'] ?? false,
              isSpicy: data['isSpicy'] ?? false,
              calories: data['calories'] ?? 0,
              protein: data['protein'] ?? 0.0,
              carbs: data['carbs'] ?? 0.0,
              fat: data['fat'] ?? 0.0,
            );

            dishes.add(dish);
          } catch (e) {
            print('❌ Erreur création DishModel pour ${doc.id}: $e');
            // Continuer avec le plat suivant
          }
        }
      }

      // Trier par popularité
      dishes.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

      return dishes;
    } catch (e) {
      print('❌ Erreur recherche plats Firestore: $e');
      return [];
    }
  }
}
