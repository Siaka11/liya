import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_products.dart';
import '../../data/datasources/search_remote_data_source.dart';
import '../../data/repositories/search_repository_impl.dart';

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

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final dataSource =
      SearchRemoteDataSourceImpl(apiUrl: 'http://api-restaurant.toptelsig.com');
  final repository = SearchRepositoryImpl(dataSource);
  final usecase = SearchProducts(repository);
  return SearchNotifier(usecase);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchProducts usecase;
  SearchNotifier(this.usecase) : super(SearchState());

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await usecase(query);
      state = state.copyWith(isLoading: false, results: results, error: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erreur lors de la recherche');
    }
  }
}
