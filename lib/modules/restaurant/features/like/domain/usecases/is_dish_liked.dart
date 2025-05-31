import 'package:liya/modules/restaurant/features/like/domain/repositories/like_repository.dart';

class IsDishLiked {
  final LikeRepository repository;

  IsDishLiked(this.repository);

  Future<bool> call(String dishId, String userId) async {
    return repository.isDishLiked(dishId, userId);
  }
}
