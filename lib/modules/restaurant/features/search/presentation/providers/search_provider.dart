import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_result.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/datasources/search_firestore_data_source.dart';

class SearchState {
  final bool isLoading;
  final String? error;
  final List<SearchResult> results;

  SearchState({
    this.isLoading = false,
    this.error,
    this.results = const [],
  });

  SearchState copyWith({
    bool? isLoading,
    String? error,
    List<SearchResult>? results,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
    );
  }
}

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

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchNotifier(repository);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepositoryImpl _repository;
  SearchNotifier(this._repository) : super(SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(isLoading: false, results: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _repository.search(query);
      state = state.copyWith(isLoading: false, results: results, error: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erreur lors de la recherche: $e');
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
      state = state.copyWith(isLoading: false, results: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _repository.advancedSearch(
        query: query,
        category: category,
        restaurantId: restaurantId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      state = state.copyWith(isLoading: false, results: results, error: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erreur lors de la recherche avancée: $e');
    }
  }

  /// Obtenir des suggestions de recherche
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      return await _repository.getSearchSuggestions(query);
    } catch (e) {
      print('❌ Erreur suggestions: $e');
      return [];
    }
  }

  /// Effacer les résultats de recherche
  void clearSearch() {
    state = state.copyWith(results: [], error: null);
  }
}
