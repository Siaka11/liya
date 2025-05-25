import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/search_remote_data_source.dart';
import '../data/repositories/search_repository_impl.dart';
import '../domain/entities/search_result.dart';
import '../domain/usecases/search_products.dart';

final searchProvider =
StateNotifierProvider<SearchNotifier, List<SearchResult>>((ref) {
  final dataSource =
  SearchRemoteDataSourceImpl(apiUrl: 'http://api-restaurant.toptelsig.com');
  final repository = SearchRepositoryImpl(dataSource);
  final usecase = SearchProducts(repository);
  return SearchNotifier(usecase);
});

class SearchNotifier extends StateNotifier<List<SearchResult>> {
  final SearchProducts usecase;
  SearchNotifier(this.usecase) : super([]);

  Future<void> search(String query) async {
    state = await usecase(query);
  }
}
