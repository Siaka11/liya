import '../entities/popular_dish.dart';

abstract class PopularDishRepository {
  Future<List<PopularDish>> getPopularDishes();
}