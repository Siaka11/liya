import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/datasources/dish_remote_data_source.dart';
import '../data/repositories/dish_repository_impl.dart';
import '../domain/entities/dish.dart';
import '../domain/usecases/get_dishes_by_restaurant.dart';


class DishState {
  final List<Dish>? dishes;
  final bool isLoading;
  final String? error;

  DishState({
    this.dishes,
    this.isLoading = false,
    this.error,
  });

  DishState copyWith({
    List<Dish>? dishes,
    bool? isLoading,
    String? error,
  }) {
    return DishState(
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DishController extends StateNotifier<DishState> {
  final GetDishesByRestaurant getDishesByRestaurant;

  DishController(this.getDishesByRestaurant) : super(DishState());

  Future<void> loadDishes(String restaurantId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getDishesByRestaurant(restaurantId);
    result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: 'Erreur lors du chargement des plats');
      },
          (dishes) {
        state = state.copyWith(isLoading: false, dishes: dishes);
      },
    );
  }
}

final dishControllerProvider = StateNotifierProvider.family<DishController, DishState, String>(
      (ref, restaurantId) {
    final client = http.Client();
    final remoteDataSource = DishRemoteDataSourceImpl(client: client); // Devrait être valide
    final repository = DishRepositoryImpl(remoteDataSource: remoteDataSource);
    final getDishesByRestaurant = GetDishesByRestaurant(repository);
    return DishController(getDishesByRestaurant);
  },
);