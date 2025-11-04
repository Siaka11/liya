import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// État pour les catégories Firebase
class CategoriesFirebaseState {
  final List<Map<String, dynamic>>? categories;
  final bool isLoading;
  final String? error;

  CategoriesFirebaseState({
    this.categories,
    this.isLoading = false,
    this.error,
  });

  CategoriesFirebaseState copyWith({
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoriesFirebaseState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier pour gérer les catégories Firebase
class CategoriesFirebaseNotifier
    extends StateNotifier<CategoriesFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CategoriesFirebaseNotifier() : super(CategoriesFirebaseState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔥 Début chargement catégories Firebase...');

      // Récupérer toutes les catégories (sans filtre isActive d'abord pour debug)
      final categoriesSnapshot =
          await _firestore.collection('categories').orderBy('name').get();

      print(
          '🔥 Catégories trouvées dans Firestore: ${categoriesSnapshot.docs.length}');

      if (categoriesSnapshot.docs.isEmpty) {
        print('⚠️ Aucune catégorie trouvée dans la collection categories');
        state = state.copyWith(
          categories: [],
          isLoading: false,
        );
        return;
      }

      final List<Map<String, dynamic>> categories = [];

      for (final doc in categoriesSnapshot.docs) {
        final categoryData = doc.data();
        print('🔥 Catégorie trouvée: ${doc.id}');
        print('🔥 Données catégorie: $categoryData');

        // Vérifier si la catégorie est active (optional)
        final isActive = categoryData['isActive'] ?? true;
        if (!isActive) {
          print('🔥 Catégorie ${doc.id} non active, ignorée');
          continue;
        }

        // Compter le nombre de plats dans cette catégorie (simplifié)
        int dishesCount = 0;
        try {
          // Essayer d'abord avec l'ancien système (categorie field)
          final dishesSnapshot = await _firestore
              .collection('dishes')
              .where('categorie', isEqualTo: categoryData['name'])
              .where('isAvailable', isEqualTo: true)
              .get();
          dishesCount = dishesSnapshot.docs.length;
          print(
              '🔥 Plats trouvés pour ${categoryData['name']}: $dishesCount (ancien système)');
        } catch (e) {
          print('Erreur comptage plats (ancien système): $e');
          // Si l'ancien système échoue, essayer le nouveau
          try {
            final dishesSnapshot = await _firestore
                .collection('dishes')
                .where('categories', arrayContains: doc.id)
                .where('isAvailable', isEqualTo: true)
                .get();
            dishesCount = dishesSnapshot.docs.length;
            print(
                '🔥 Plats trouvés pour ${doc.id}: $dishesCount (nouveau système)');
          } catch (e2) {
            print('Erreur comptage plats (nouveau système): $e2');
            dishesCount = 0; // Default to 0 if both fail
          }
        }

        categories.add({
          'id': doc.id,
          'name': categoryData['name'] ?? 'Catégorie inconnue',
          'description': categoryData['description'] ?? '',
          'imageUrl': categoryData['imageUrl'] ??
              '', // Correction: utiliser imageUrl au lieu de image_url
          'icon': categoryData['icon'] ?? 'fastfood',
          'color': categoryData['color'] ?? '#FF6B6B',
          'is_active': isActive,
          'dishes_count': dishesCount,
          'created_at': categoryData['createdAt'],
          'updated_at': categoryData['updatedAt'],
        });
      }

      print('🔥 Catégories finales: ${categories.length}');
      for (final category in categories) {
        print(
            '✅ Catégorie: ${category['name']} - Plats: ${category['dishes_count']}');
      }

      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Erreur lors du chargement des catégories: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des catégories: $e',
      );
    }
  }

  void refresh() {
    loadCategories();
  }
}

// Provider pour les catégories Firebase
final categoriesFirebaseProvider =
    StateNotifierProvider<CategoriesFirebaseNotifier, CategoriesFirebaseState>(
        (ref) {
  return CategoriesFirebaseNotifier();
});

// Provider pour charger les plats d'une catégorie spécifique
class DishesByCategoryNotifier extends StateNotifier<CategoriesFirebaseState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DishesByCategoryNotifier() : super(CategoriesFirebaseState());

  Future<void> loadDishesByCategory(
      String categoryId, String categoryName) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔥 Chargement plats pour catégorie: $categoryName ($categoryId)');

      List<Map<String, dynamic>> dishes = [];

      // Essayer d'abord avec le nouveau système (array de catégories)
      try {
        final dishesSnapshot = await _firestore
            .collection('dishes')
            .where('categories', arrayContains: categoryId)
            .where('isAvailable', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

        dishes = await _processDishesSnapshot(dishesSnapshot);
      } catch (e) {
        print('Nouveau système échoué, essai ancien système: $e');
      }

      // Fallback vers l'ancien système si nouveau système échoue
      if (dishes.isEmpty) {
        try {
          final dishesSnapshot = await _firestore
              .collection('dishes')
              .where('categorie', isEqualTo: categoryName)
              .where('isAvailable', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

          dishes = await _processDishesSnapshot(dishesSnapshot);
        } catch (e) {
          print('Ancien système échoué aussi: $e');
        }
      }

      print('Plats trouvés pour $categoryName: ${dishes.length}');

      state = state.copyWith(
        categories: dishes, // Réutilise le même état pour stocker les plats
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement des plats par catégorie: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des plats: $e',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _processDishesSnapshot(
      QuerySnapshot snapshot) async {
    final List<Map<String, dynamic>> dishes = [];

    for (final doc in snapshot.docs) {
      final dishData = doc.data() as Map<String, dynamic>;

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
        print('Erreur restaurant: $e');
      }

      // Calculer le prix final avec promotions
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
        'categories': dishData['categories'] ??
            [dishData['categorie']], // Support des deux systèmes
        'preparation_time': dishData['preparation_time'] ?? 30,
        'rating': (dishData['rating'] ?? 0.0).toDouble(),
        'rating_count': dishData['rating_count'] ?? 0,
        'order_count': dishData['order_count'] ?? 0,
        'view_count': dishData['view_count'] ?? 0,
        'popularity_score': dishData['popularity_score'] ?? 0.0,
        'createdAt': dishData['createdAt'],
        'updatedAt': dishData['updatedAt'],
      });
    }

    return dishes;
  }
}

// Provider pour les plats par catégorie
final dishesByCategoryProvider = StateNotifierProvider.family<
    DishesByCategoryNotifier,
    CategoriesFirebaseState,
    String>((ref, categoryId) {
  return DishesByCategoryNotifier();
});
