import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_firestore_data_source.dart';
import '../models/search_result_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchFirestoreDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SearchResult>> search(String query) async {
    try {
      final results = await remoteDataSource.search(query);
      return results;
    } catch (e) {
      print('❌ Erreur repository recherche: $e');
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
      final results = await remoteDataSource.advancedSearch(
        query: query,
        category: category,
        restaurantId: restaurantId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      return results;
    } catch (e) {
      print('❌ Erreur repository recherche avancée: $e');
      return [];
    }
  }

  /// Obtenir des suggestions de recherche
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      return await remoteDataSource.getSearchSuggestions(query);
    } catch (e) {
      print('❌ Erreur repository suggestions: $e');
      return [];
    }
  }
}
