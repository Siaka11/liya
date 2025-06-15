import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/popular_dish_remote_data_source.dart';
import '../data/repositories/popular_dish_repository_impl.dart';
import '../domain/entities/popular_dish.dart';
import '../domain/usecases/get_popular_dish_usecase.dart';

final popularDishControllerProvider = StateNotifierProvider<PopularDishController, PopularDishState>((ref) {
  final client = http.Client();
  final remoteDataSource = PopularDishRemoteDataSourceImpl(client: client);
  final repository = PopularDishRepositoryImpl(remoteDataSource: remoteDataSource);
  final useCase = GetPopularDishUseCase(repository: repository);
  return PopularDishController(useCase);
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

class PopularDishController extends StateNotifier<PopularDishState> {
  final GetPopularDishUseCase _useCase;

  PopularDishController(this._useCase) : super(PopularDishState());

  Future<void> loadPopularDishes() async {
    state = state.copyWith(isLoading: true);
    try {
      final dishes = await _useCase.getAllPopularSish();
      state = state.copyWith(popularDishes: dishes, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false, popularDishes: null);
    }
  }
}