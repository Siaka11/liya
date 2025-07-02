import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/delivery_service.dart';
import '../domain/entities/delivery_user.dart';
import '../domain/entities/delivery_order.dart';

class DeliveryAdminState {
  final List<DeliveryUser> availableDeliveryUsers;
  final List<DeliveryOrder> pendingOrders;
  final bool isLoading;
  final String? error;

  const DeliveryAdminState({
    this.availableDeliveryUsers = const [],
    this.pendingOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DeliveryAdminState copyWith({
    List<DeliveryUser>? availableDeliveryUsers,
    List<DeliveryOrder>? pendingOrders,
    bool? isLoading,
    String? error,
  }) {
    return DeliveryAdminState(
      availableDeliveryUsers:
          availableDeliveryUsers ?? this.availableDeliveryUsers,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DeliveryAdminNotifier extends StateNotifier<DeliveryAdminState> {
  DeliveryAdminNotifier() : super(const DeliveryAdminState()) {
    loadData();
  }

  // Charger les données
  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true);

      final availableUsers = await DeliveryService.getAvailableDeliveryUsers();
      final pendingOrders = await DeliveryService.getPendingOrders();

      state = state.copyWith(
        availableDeliveryUsers: availableUsers,
        pendingOrders: pendingOrders,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors du chargement: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Assigner une commande à un livreur
  Future<void> assignOrderToDeliveryUser(
    DeliveryOrder order,
    DeliveryUser deliveryUser,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      await DeliveryService.assignOrderToDeliveryUser(
        order.id,
        deliveryUser.phoneNumber,
        deliveryUser.fullName,
      );

      // Recharger les données
      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de l\'assignation: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Créer une nouvelle commande de livraison
  Future<void> createDeliveryOrder({
    required String customerPhoneNumber,
    required String customerName,
    required String customerAddress,
    required DeliveryType type,
    required double amount,
    required double deliveryFee,
    required String description,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final order = DeliveryOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerPhoneNumber: customerPhoneNumber,
        customerName: customerName,
        customerAddress: customerAddress,
        type: type,
        status: DeliveryStatus.reception,
        amount: amount,
        deliveryFee: deliveryFee,
        description: description,
        createdAt: DateTime.now(),
      );

      await DeliveryService.createDeliveryOrder(order);

      // Recharger les données
      await loadData();
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la création de la commande: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Rafraîchir les données
  Future<void> refreshData() async {
    await loadData();
  }

  // Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final deliveryAdminProvider =
    StateNotifierProvider<DeliveryAdminNotifier, DeliveryAdminState>((ref) {
  return DeliveryAdminNotifier();
});

// Provider pour les livreurs disponibles
final availableDeliveryUsersProvider = Provider<List<DeliveryUser>>((ref) {
  final state = ref.watch(deliveryAdminProvider);
  return state.availableDeliveryUsers;
});

// Provider pour les commandes en attente
final adminPendingOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryAdminProvider);
  return state.pendingOrders;
});
