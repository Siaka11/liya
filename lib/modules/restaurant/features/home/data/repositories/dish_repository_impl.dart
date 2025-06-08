import 'package:dartz/dartz.dart';

import '../../../../core/failure.dart';
import '../../domain/entities/dish.dart';
import '../../domain/repositories/dish_repository.dart';
import '../datasources/dish_remote_data_source.dart';

class DishRepositoryImpl implements DishRepository {
  final DishRemoteDataSource remoteDataSource;

  DishRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Dish>>> getDishesByRestaurant(
      String restaurantId) async {
    try {
      final dishModels =
          await remoteDataSource.getDishesByRestaurant(restaurantId);
      return Right(dishModels); // Conversion implicite de DishModel à Dish
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  Future<List<Dish>> getAllDishesFromMySQL() async {
    try {
      final dishModels = await remoteDataSource.getAllDishes();
      return dishModels;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de tous les plats : $e');
    }
  }
}
