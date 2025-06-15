import 'package:liya/modules/restaurant/features/like/domain/repositories/like_repository.dart';

class UnlikeDish {
  final LikeRepository repository;

  UnlikeDish(this.repository);

  Future<void> call(String dishId, String userId) async {
    await repository.unlikeDish(dishId, userId);
  }
}
