import '../entities/category.dart';
import '../entities/dish.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<List<Dish>> getDishesByCategory(String categoryId);
}
