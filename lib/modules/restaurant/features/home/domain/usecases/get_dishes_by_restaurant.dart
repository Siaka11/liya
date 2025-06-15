

import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../entities/dish.dart';
import '../repositories/dish_repository.dart';

class GetDishesByRestaurant {
  final DishRepository repository;

  GetDishesByRestaurant(this.repository);

  Future<Either<Failure, List<Dish>>> call(String restaurantId) async {
    return await repository.getDishesByRestaurant(restaurantId);
  }
}