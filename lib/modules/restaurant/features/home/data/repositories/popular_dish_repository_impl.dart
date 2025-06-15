import '../../domain/entities/popular_dish.dart';
import '../../domain/repositories/popular_dish_repository.dart';
import '../datasources/popular_dish_remote_data_source.dart';

class PopularDishRepositoryImpl implements PopularDishRepository {
  final PopularDishRemoteDataSource remoteDataSource;

  PopularDishRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PopularDish>> getPopularDishes() async {
    try {
      return await remoteDataSource.getPopularDishes();
    } catch (e) {
      throw Exception('Failed to fetch popular dishes: $e');
    }
  }
}