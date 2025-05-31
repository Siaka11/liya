import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/domain/entities/popular_dish.dart';

final popularDishProvider =
    StateNotifierProvider<PopularDishNotifier, PopularDishState>((ref) {
  return PopularDishNotifier();
});

class PopularDishState {
  final List<PopularDish>? popularDishes;
  final bool isLoading;
  final String? error;

  PopularDishState({
    this.popularDishes,
    this.isLoading = false,
    this.error,
  });

  PopularDishState copyWith({
    List<PopularDish>? popularDishes,
    bool? isLoading,
    String? error,
  }) {
    return PopularDishState(
      popularDishes: popularDishes ?? this.popularDishes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PopularDishNotifier extends StateNotifier<PopularDishState> {
  PopularDishNotifier() : super(PopularDishState());

  Future<void> loadPopularDishes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Simuler un chargement de données
      await Future.delayed(const Duration(seconds: 1));

    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors du chargement des plats populaires',
        isLoading: false,
      );
    }
  }
}
