import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/domain/entities/home_state.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());

  void loadRestaurants() {
    // Implémenter le chargement des restaurants
  }
}

class HomeState {
  final List<dynamic>? restaurants;
  final bool isLoading;
  final String? error;

  HomeState({
    this.restaurants,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<dynamic>? restaurants,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
