import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedQuantityNotifier extends StateNotifier<Map<String, int>> {
  SelectedQuantityNotifier() : super({});

  void setQuantity(String dishId, int quantity) {
    state = {...state, dishId: quantity};
  }

  int getQuantity(String dishId) {
    return state[dishId] ?? 0;
  }
}

final selectedQuantityProvider = StateNotifierProvider<SelectedQuantityNotifier, Map<String, int>>((ref) {
  return SelectedQuantityNotifier();
});