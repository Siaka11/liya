

import '../entities/popular_dish.dart';
import '../repositories/popular_dish_repository.dart';

class GetPopularDishUseCase {
  final PopularDishRepository repository;

  GetPopularDishUseCase({required this.repository});

  Future<List<PopularDish>> getAllPopularSish() async {
    return await repository.getPopularDishes();
  }
}