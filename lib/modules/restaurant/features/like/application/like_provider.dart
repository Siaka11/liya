import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:liya/core/providers.dart';

import '../domain/entities/liked_dish.dart';
import '../domain/repositories/like_repository.dart';
import '../domain/usecases/get_liked_dishes.dart';
import '../domain/usecases/like_dish.dart';
import '../domain/usecases/unlike_dish.dart';
import '../domain/usecases/is_dish_liked.dart';

class LikeState {
  final List<LikedDish> likedDishes;
  final bool isLoading;
  final String? error;

  const LikeState({
    this.likedDishes = const [],
    this.isLoading = false,
    this.error,
  });

  LikeState copyWith({
    List<LikedDish>? likedDishes,
    bool? isLoading,
    String? error,
  }) {
    return LikeState(
      likedDishes: likedDishes ?? this.likedDishes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LikeNotifier extends StateNotifier<LikeState> {
  final LikeRepository repository;
  final String userId;

  LikeNotifier(this.repository, this.userId) : super(const LikeState()) {
    loadLikedDishes();
  }

  Future<void> loadLikedDishes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dishes = await repository.getLikedDishes(userId);
      state = state.copyWith(likedDishes: dishes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(LikedDish dish) async {
    try {
      final isLiked = await repository.isDishLiked(dish.id, userId);
      if (isLiked) {
        await repository.unlikeDish(dish.id, userId);
        state = state.copyWith(
          likedDishes: state.likedDishes.where((d) => d.id != dish.id).toList(),
        );
      } else {
        await repository.likeDish(dish);
        state = state.copyWith(
          likedDishes: [...state.likedDishes, dish],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> isDishLiked(String dishId) async {
    return await repository.isDishLiked(dishId, userId);
  }
}

final likeProvider =
    StateNotifierProvider.family<LikeNotifier, LikeState, String>(
  (ref, userId) {
    final repository = ref.read(likeRepositoryProvider);
    return LikeNotifier(repository, userId);
  },
);

final unlikeDishProvider = Provider<UnlikeDish>((ref) {
  return UnlikeDish(ref.watch(likeRepositoryProvider));
});

final isDishLikedProvider =
    FutureProvider.family<bool, ({String dishId, String userId})>(
        (ref, params) async {
  final usecase = IsDishLiked(ref.watch(likeRepositoryProvider));
  return usecase(params.dishId, params.userId);
});

final getLikedDishesProvider =
    FutureProvider.family<List<LikedDish>, String>((ref, userId) async {
  final usecase = GetLikedDishes(ref.watch(likeRepositoryProvider));
  return usecase(userId);
});
