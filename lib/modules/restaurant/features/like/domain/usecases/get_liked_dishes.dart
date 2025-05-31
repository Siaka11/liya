import 'package:liya/modules/restaurant/features/like/domain/entities/liked_dish.dart';
import 'package:liya/modules/restaurant/features/like/domain/repositories/like_repository.dart';

class GetLikedDishes {
  final LikeRepository repository;

  GetLikedDishes(this.repository);

  Future<List<LikedDish>> call(String userId) async {
    return repository.getLikedDishes(userId);
  }
}
