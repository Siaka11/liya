import 'package:liya/modules/restaurant/features/like/domain/entities/liked_dish.dart';
import 'package:liya/modules/restaurant/features/like/domain/repositories/like_repository.dart';

class LikeDish {
  final LikeRepository repository;

  LikeDish(this.repository);

  Future<void> call(LikedDish dish) async {
    await repository.likeDish(dish);
  }
}
