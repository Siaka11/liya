import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/promotion_service.dart';

final promotionServiceProvider = Provider<PromotionService>((ref) {
  return PromotionService();
});

final activePromotionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final promotionService = ref.read(promotionServiceProvider);
  return await promotionService.getActivePromotions();
});

final dishPromotionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, dishId) async {
  final promotionService = ref.read(promotionServiceProvider);
  return await promotionService.getDishPromotions(dishId);
});

final dishPriceProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, dishData) async {
  final promotionService = ref.read(promotionServiceProvider);
  final dishId = dishData['id'] as String;
  final basePrice = (dishData['price'] as num).toDouble();
  return await promotionService.calculateDishPrice(dishId, basePrice);
});

class PromotionNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final PromotionService _promotionService;

  PromotionNotifier(this._promotionService)
      : super(const AsyncValue.loading()) {
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    state = const AsyncValue.loading();
    try {
      final promotions = await _promotionService.getActivePromotions();
      state = AsyncValue.data(promotions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshPromotions() async {
    await _loadPromotions();
  }

  Future<void> applyPromotion(String promotionId) async {
    try {
      await _promotionService.applyPromotion(promotionId);
      // Recharger les promotions après application
      await _loadPromotions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final promotionNotifierProvider = StateNotifierProvider<PromotionNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final promotionService = ref.read(promotionServiceProvider);
  return PromotionNotifier(promotionService);
});
