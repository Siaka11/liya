import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_result_model.dart';
import '../../domain/entities/search_result.dart';

class SearchFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Recherche dans Firestore
  Future<List<SearchResult>> search(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final searchQuery = query.toLowerCase().trim();
      List<SearchResult> results = [];

      // Recherche dans les plats
      final dishesQuery = await _firestore
          .collection('dishes')
          .where('isAvailable', isEqualTo: true)
          .get();

      for (var doc in dishesQuery.docs) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        final description =
            (data['description'] as String?)?.toLowerCase() ?? '';
        final category = (data['category'] as String?)?.toLowerCase() ?? '';

        if (name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            category.contains(searchQuery)) {
          results.add(SearchResultModel(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            type: 'dish',
            category: data['categorie'] ?? data['category'] ?? '',
            restaurantId: data['restaurantId'] ?? '',
            restaurantName: data['restaurantName'] ?? '',
          ));
        }
      }

      // Recherche dans les restaurants
      final restaurantsQuery = await _firestore
          .collection('restaurants')
          .where('isAvailable', isEqualTo: true)
          .get();

      for (var doc in restaurantsQuery.docs) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        final description =
            (data['description'] as String?)?.toLowerCase() ?? '';
        final cuisine = (data['cuisine'] as String?)?.toLowerCase() ?? '';

        if (name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            cuisine.contains(searchQuery)) {
          results.add(SearchResultModel(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            price: 0.0, // Les restaurants n'ont pas de prix
            type: 'restaurant',
            category: data['cuisine'] ?? '',
            restaurantId: doc.id,
            restaurantName: data['name'] ?? '',
          ));
        }
      }

      // Recherche dans les catégories
      final categoriesQuery = await _firestore
          .collection('categories')
          .where('isAvailable', isEqualTo: true)
          .get();

      for (var doc in categoriesQuery.docs) {
        final data = doc.data();
        final name = (data['name'] as String?)?.toLowerCase() ?? '';
        final description =
            (data['description'] as String?)?.toLowerCase() ?? '';

        if (name.contains(searchQuery) || description.contains(searchQuery)) {
          results.add(SearchResultModel(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            price: 0.0, // Les catégories n'ont pas de prix
            type: 'category',
            category: data['name'] ?? '',
            restaurantId: '',
            restaurantName: '',
          ));
        }
      }

      // Trier les résultats par pertinence
      results.sort((a, b) {
        // Priorité aux plats
        if (a.type == 'dish' && b.type != 'dish') return -1;
        if (a.type != 'dish' && b.type == 'dish') return 1;

        // Puis par correspondance exacte du nom
        final aExactMatch = a.name.toLowerCase() == searchQuery;
        final bExactMatch = b.name.toLowerCase() == searchQuery;
        if (aExactMatch && !bExactMatch) return -1;
        if (!aExactMatch && bExactMatch) return 1;

        // Puis par correspondance au début du nom
        final aStartsWith = a.name.toLowerCase().startsWith(searchQuery);
        final bStartsWith = b.name.toLowerCase().startsWith(searchQuery);
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        return 0;
      });

      return results;
    } catch (e) {
      print('❌ Erreur recherche Firestore: $e');
      return [];
    }
  }

  /// Recherche avancée avec filtres
  Future<List<SearchResult>> advancedSearch({
    required String query,
    String? category,
    String? restaurantId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      List<SearchResult> results = await search(query);

      // Filtrer par catégorie
      if (category != null && category.isNotEmpty) {
        results = results
            .where((r) => r.category.toLowerCase() == category.toLowerCase())
            .toList();
      }

      // Filtrer par restaurant
      if (restaurantId != null && restaurantId.isNotEmpty) {
        results = results.where((r) => r.restaurantId == restaurantId).toList();
      }

      // Filtrer par prix
      if (minPrice != null) {
        results = results.where((r) => r.price >= minPrice).toList();
      }

      if (maxPrice != null) {
        results = results.where((r) => r.price <= maxPrice).toList();
      }

      return results;
    } catch (e) {
      print('❌ Erreur recherche avancée Firestore: $e');
      return [];
    }
  }

  /// Recherche de suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final searchQuery = query.toLowerCase().trim();
      Set<String> suggestions = {};

      // Suggestions de plats
      final dishesQuery = await _firestore
          .collection('dishes')
          .where('active', isEqualTo: true)
          .get();

      for (var doc in dishesQuery.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';

        if (name.toLowerCase().contains(searchQuery)) {
          suggestions.add(name);
        }
      }

      // Suggestions de restaurants
      final restaurantsQuery = await _firestore
          .collection('restaurants')
          .where('active', isEqualTo: true)
          .get();

      for (var doc in restaurantsQuery.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';

        if (name.toLowerCase().contains(searchQuery)) {
          suggestions.add(name);
        }
      }

      // Suggestions de catégories
      final categoriesQuery = await _firestore
          .collection('categories')
          .where('active', isEqualTo: true)
          .get();

      for (var doc in categoriesQuery.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';

        if (name.toLowerCase().contains(searchQuery)) {
          suggestions.add(name);
        }
      }

      return suggestions.take(10).toList(); // Limiter à 10 suggestions
    } catch (e) {
      print('❌ Erreur suggestions Firestore: $e');
      return [];
    }
  }
}
