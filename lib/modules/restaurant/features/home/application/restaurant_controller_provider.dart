

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/datasources/restaurant_remote_datasource.dart';
import '../data/repositories/restaurant_repository_impl.dart';
import '../domain/entities/restaurant.dart';
import '../domain/repositories/restaurant_repository.dart';
import '../domain/usecases/get_restaurant_usecase.dart';

class RestaurantState {
  final bool isLoading;
  final List<Restaurant>? restaurants;
  final String? error;

  RestaurantState({
    required this.isLoading,
    this.restaurants,
    this.error,
  });

  RestaurantState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    String? error,
  }) {
    return RestaurantState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      error: error ?? this.error,
    );
  }
}

class RestaurantController extends StateNotifier<RestaurantState> {
  final GetRestaurantsUseCase getRestaurantsUseCase;

  RestaurantController({required this.getRestaurantsUseCase})
      : super(RestaurantState(isLoading: false));

  Future<void> loadRestaurants() async {
    if (state.restaurants != null) return;
    state = state.copyWith(isLoading: true);
    try {
      final restaurants = await getRestaurantsUseCase.execute();
      state = state.copyWith(isLoading: false, restaurants: restaurants);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return RestaurantRepositoryImpl(RestaurantRemoteDatasource(http.Client()));
});

final getRestaurantsUseCaseProvider = Provider<GetRestaurantsUseCase>((ref) {
  return GetRestaurantsUseCase(ref.watch(restaurantRepositoryProvider));
});

final restaurantControllerProvider = StateNotifierProvider<RestaurantController, RestaurantState>((ref) {
  return RestaurantController(
    getRestaurantsUseCase: ref.watch(getRestaurantsUseCaseProvider),
  );
});