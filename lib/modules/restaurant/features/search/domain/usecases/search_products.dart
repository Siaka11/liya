import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchProducts {
  final SearchRepository repository;
  SearchProducts(this.repository);

  Future<List<SearchResult>> call(String query) {
    return repository.search(query);
  }
}
