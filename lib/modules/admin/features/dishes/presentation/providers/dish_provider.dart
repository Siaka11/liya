import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/dish_remote_data_source.dart';
import '../../data/models/dish_model.dart';
import 'package:http/http.dart' as http;

final dishRepositoryProvider = Provider((ref) {
  return DishRemoteDataSourceImpl(http.Client());
});

class DishState {
  final List<DishModel> dishes;
  final bool isLoading;
  final String? error;
  final String? selectedDishId;
  final File? selectedImage;

  DishState({
    required this.dishes,
    required this.isLoading,
    this.error,
    this.selectedDishId,
    this.selectedImage,
  });

  DishState copyWith({
    List<DishModel>? dishes,
    bool? isLoading,
    String? error,
    String? selectedDishId,
    File? selectedImage,
  }) {
    return DishState(
      dishes: dishes ?? this.dishes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDishId: selectedDishId ?? this.selectedDishId,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class DishNotifier extends StateNotifier<DishState> {
  final DishRemoteDataSource _repository;

  DishNotifier(this._repository)
      : super(DishState(
          dishes: [],
          isLoading: false,
        ));

  Future<void> loadDishes(String restaurantId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dishes = await _repository.getDishes(restaurantId);
      state = state.copyWith(dishes: dishes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectDish(String dishId) async {
    state = state.copyWith(selectedDishId: dishId);
  }

  Future<void> selectImage(File image) async {
    state = state.copyWith(selectedImage: image);
  }

  Future<void> uploadImage(String dishId) async {
    if (state.selectedImage == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final imageUrl =
          await _repository.uploadDishImage(state.selectedImage!, dishId);
      await _repository.updateDishImage(dishId, imageUrl);
      state = state.copyWith(isLoading: false, selectedImage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteImage(String dishId, String imageUrl) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteDishImage(imageUrl);
      await _repository.updateDishImage(dishId, '');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dishProvider = StateNotifierProvider<DishNotifier, DishState>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return DishNotifier(repository);
});
