import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

class RestaurantFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Recherche de restaurants dans Firestore
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final searchQuery = query.toLowerCase().trim();
      List<RestaurantModel> results = [];

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
        final address = (data['address'] as String?)?.toLowerCase() ?? '';

        if (name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            cuisine.contains(searchQuery) ||
            address.contains(searchQuery)) {
          results.add(RestaurantModel(
            id: doc.id,
            name: data['name'] ?? '',
            image: data['imageUrl'] ?? data['image'] ?? '',
            address: data['address'] ?? '',
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            cuisine: data['cuisine'] ?? '',
            isOpen: data['isOpen'] ?? data['active'] ?? true,
            categories: List<String>.from(data['categories'] ?? []),
            location: data['location'] ?? {},
            phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
            description: data['description'] ?? '',
            photos: List<String>.from(data['photos'] ?? []),
            openingHours: data['openingHours'] ?? {},
            deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
            deliveryTime: data['deliveryTime'] ?? 0,
            minimumOrder: (data['minimumOrder'] as num?)?.toDouble() ??
                (data['minOrder'] as num?)?.toDouble() ??
                0.0,
            isFeatured: data['isFeatured'] ?? false,
            isPromoted: data['isPromoted'] ?? false,
            promotion: data['promotion'],
          ));
        }
      }

      // Trier les résultats par pertinence
      results.sort((a, b) {
        // Priorité aux correspondances exactes du nom
        final aExactMatch = a.name.toLowerCase() == searchQuery;
        final bExactMatch = b.name.toLowerCase() == searchQuery;
        if (aExactMatch && !bExactMatch) return -1;
        if (!aExactMatch && bExactMatch) return 1;

        // Puis par correspondance au début du nom
        final aStartsWith = a.name.toLowerCase().startsWith(searchQuery);
        final bStartsWith = b.name.toLowerCase().startsWith(searchQuery);
        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        // Puis par note
        return b.rating.compareTo(a.rating);
      });

      return results;
    } catch (e) {
      print('❌ Erreur recherche restaurants Firestore: $e');
      return [];
    }
  }

  /// Recherche avancée avec filtres
  Future<List<RestaurantModel>> advancedRestaurantSearch({
    required String query,
    String? cuisine,
    double? minRating,
    double? maxDeliveryFee,
    double? maxDeliveryTime,
  }) async {
    try {
      List<RestaurantModel> results = await searchRestaurants(query);

      // Filtrer par cuisine
      if (cuisine != null && cuisine.isNotEmpty) {
        results = results
            .where((r) => r.cuisine.toLowerCase() == cuisine.toLowerCase())
            .toList();
      }

      // Filtrer par note minimale
      if (minRating != null) {
        results = results.where((r) => r.rating >= minRating).toList();
      }

      // Filtrer par frais de livraison maximum
      if (maxDeliveryFee != null) {
        results =
            results.where((r) => r.deliveryFee <= maxDeliveryFee).toList();
      }

      // Filtrer par temps de livraison maximum (en minutes)
      if (maxDeliveryTime != null) {
        results = results.where((r) {
          final deliveryTime = r.deliveryTime;
          return deliveryTime <= maxDeliveryTime;
        }).toList();
      }

      return results;
    } catch (e) {
      print('❌ Erreur recherche avancée restaurants Firestore: $e');
      return [];
    }
  }

  /// Obtenir des suggestions de recherche pour les restaurants
  Future<List<String>> getRestaurantSearchSuggestions(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final searchQuery = query.toLowerCase().trim();
      Set<String> suggestions = {};

      // Suggestions de noms de restaurants
      final restaurantsQuery = await _firestore
          .collection('restaurants')
          .where('isAvailable', isEqualTo: true)
          .get();

      for (var doc in restaurantsQuery.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? '';

        if (name.toLowerCase().contains(searchQuery)) {
          suggestions.add(name);
        }
      }

      // Suggestions de cuisines
      final cuisinesQuery = await _firestore
          .collection('restaurants')
          .where('isAvailable', isEqualTo: true)
          .get();

      for (var doc in cuisinesQuery.docs) {
        final data = doc.data();
        final cuisine = data['cuisine'] as String? ?? '';

        if (cuisine.toLowerCase().contains(searchQuery)) {
          suggestions.add(cuisine);
        }
      }

      return suggestions.take(10).toList(); // Limiter à 10 suggestions
    } catch (e) {
      print('❌ Erreur suggestions restaurants Firestore: $e');
      return [];
    }
  }
}
