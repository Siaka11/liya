import '../../domain/entities/liked_dish.dart';
import '../../domain/repositories/like_repository.dart';
import '../datasources/like_remote_data_source.dart';

class LikeRepositoryImpl implements LikeRepository {
  final LikeRemoteDataSource _remoteDataSource;

  LikeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LikedDish>> getLikedDishes(String userId) async {
    return await _remoteDataSource.getLikedDishes(userId);
  }

  @override
  Future<void> likeDish(LikedDish dish) async {
    await _remoteDataSource.likeDish(dish);
  }

  @override
  Future<void> unlikeDish(String dishId, String userId) async {
    await _remoteDataSource.unlikeDish(dishId, userId);
  }

  @override
  Future<bool> isDishLiked(String dishId, String userId) async {
    return await _remoteDataSource.isDishLiked(dishId, userId);
  }
}
