import '../entities/liked_dish.dart';

abstract class LikeRepository {
  Future<List<LikedDish>> getLikedDishes(String userId);
  Future<void> likeDish(LikedDish dish);
  Future<void> unlikeDish(String dishId, String userId);
  Future<bool> isDishLiked(String dishId, String userId);
}
