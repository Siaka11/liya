import '../repositories/category_repository.dart';
import '../entities/dish.dart';

class GetDishesByCategory {
  final CategoryRepository repository;
  GetDishesByCategory(this.repository);

  Future<List<Dish>> call(String categoryId) {
    return repository.getDishesByCategory(categoryId);
  }
}
