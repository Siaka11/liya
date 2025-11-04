import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/search_result.dart';
import '../data/repositories/search_repository_impl.dart';
import '../data/datasources/search_firestore_data_source.dart';

// Provider pour la source de données Firestore
final searchFirestoreDataSourceProvider =
    Provider<SearchFirestoreDataSource>((ref) {
  return SearchFirestoreDataSource();
});

// Provider pour le repository
final searchRepositoryProvider = Provider<SearchRepositoryImpl>((ref) {
  final dataSource = ref.watch(searchFirestoreDataSourceProvider);
  return SearchRepositoryImpl(remoteDataSource: dataSource);
});

// Notifier pour la recherche
class SearchNotifier extends StateNotifier<AsyncValue<List<SearchResult>>> {
  final SearchRepositoryImpl _repository;

  SearchNotifier(this._repository) : super(const AsyncValue.loading());

  /// Effectuer une recherche
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final results = await _repository.search(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Recherche avancée avec filtres
  Future<void> advancedSearch({
    required String query,
    String? category,
    String? restaurantId,
    double? minPrice,
    double? maxPrice,
  }) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final results = await _repository.advancedSearch(
        query: query,
        category: category,
        restaurantId: restaurantId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Obtenir des suggestions de recherche
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      return await _repository.getSearchSuggestions(query);
    } catch (error) {
      print('❌ Erreur suggestions: $error');
      return [];
    }
  }

  /// Effacer les résultats de recherche
  void clearSearch() {
    state = const AsyncValue.data([]);
  }

  /// Vérifier si une recherche est en cours
  bool get isLoading => state.isLoading;

  /// Obtenir les résultats actuels
  List<SearchResult> get results => state.value ?? [];

  /// Vérifier s'il y a une erreur
  bool get hasError => state.hasError;

  /// Obtenir l'erreur
  Object? get error => state.error;
}

// Provider pour le notifier
final searchProvider =
    StateNotifierProvider<SearchNotifier, AsyncValue<List<SearchResult>>>(
        (ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(repository);
});
