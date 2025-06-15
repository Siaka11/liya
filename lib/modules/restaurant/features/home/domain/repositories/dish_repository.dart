

import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../entities/dish.dart';

abstract class DishRepository {
  Future<Either<Failure, List<Dish>>> getDishesByRestaurant(String restaurantId);
}