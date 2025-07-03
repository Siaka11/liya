import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/delivery_existing_service.dart';
import '../domain/entities/delivery_user.dart';
import '../domain/entities/delivery_order.dart';

class DeliveryAdminExistingState {
  final List<DeliveryUser> availableDeliveryUsers;
  final List<DeliveryOrder> pendingRestaurantOrders;
  final List<DeliveryOrder> pendingParcelOrders;
  final List<DeliveryOrder> assignedRestaurantOrders;
  final List<DeliveryOrder> assignedParcelOrders;
  final bool isLoading;
  final String? error;

  const DeliveryAdminExistingState({
    this.availableDeliveryUsers = const [],
    this.pendingRestaurantOrders = const [],
    this.pendingParcelOrders = const [],
    this.assignedRestaurantOrders = const [],
    this.assignedParcelOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DeliveryAdminExistingState copyWith({
    List<DeliveryUser>? availableDeliveryUsers,
    List<DeliveryOrder>? pendingRestaurantOrders,
    List<DeliveryOrder>? pendingParcelOrders,
    List<DeliveryOrder>? assignedRestaurantOrders,
    List<DeliveryOrder>? assignedParcelOrders,
    bool? isLoading,
    String? error,
  }) {
    return DeliveryAdminExistingState(
      availableDeliveryUsers:
          availableDeliveryUsers ?? this.availableDeliveryUsers,
      pendingRestaurantOrders:
          pendingRestaurantOrders ?? this.pendingRestaurantOrders,
      pendingParcelOrders: pendingParcelOrders ?? this.pendingParcelOrders,
      assignedRestaurantOrders:
          assignedRestaurantOrders ?? this.assignedRestaurantOrders,
      assignedParcelOrders: assignedParcelOrders ?? this.assignedParcelOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DeliveryAdminExistingNotifier
    extends StateNotifier<DeliveryAdminExistingState> {
  DeliveryAdminExistingNotifier() : super(const DeliveryAdminExistingState()) {
    loadData();
  }

  // Charger les données
  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true);

      final availableUsers =
          await DeliveryExistingService.getAvailableDeliveryUsers();
      final pendingRestaurantOrders =
          await DeliveryExistingService.getPendingRestaurantOrders();
      final pendingParcelOrders =
          await DeliveryExistingService.getPendingParcelOrders();
      final assignedRestaurantOrders =
          await DeliveryExistingService.getAssignedRestaurantOrders();
      final assignedParcelOrders =
          await DeliveryExistingService.getAssignedParcelOrders();

      state = state.copyWith(
        availableDeliveryUsers: availableUsers,
        pendingRestaurantOrders: pendingRestaurantOrders,
        pendingParcelOrders: pendingParcelOrders,
        assignedRestaurantOrders: assignedRestaurantOrders,
        assignedParcelOrders: assignedParcelOrders,
      );
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors du chargement: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Assigner une commande restaurant à un livreur
  Future<void> assignRestaurantOrderToDeliveryUser(
    DeliveryOrder order,
    DeliveryUser deliveryUser,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      await DeliveryExistingService.assignRestaurantOrderToDeliveryUser(
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

  // Assigner un colis à un livreur
  Future<void> assignParcelToDeliveryUser(
    DeliveryOrder order,
    DeliveryUser deliveryUser,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      await DeliveryExistingService.assignParcelToDeliveryUser(
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

  // Réassigner une commande restaurant à un autre livreur
  Future<void> reassignRestaurantOrder(
    DeliveryOrder order,
    DeliveryUser newDeliveryUser,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      await DeliveryExistingService.assignRestaurantOrderToDeliveryUser(
        order.id,
        newDeliveryUser.phoneNumber,
        newDeliveryUser.fullName,
      );

      // Recharger les données
      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la réassignation: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Réassigner un colis à un autre livreur
  Future<void> reassignParcel(
    DeliveryOrder order,
    DeliveryUser newDeliveryUser,
  ) async {
    try {
      state = state.copyWith(isLoading: true);

      await DeliveryExistingService.assignParcelToDeliveryUser(
        order.id,
        newDeliveryUser.phoneNumber,
        newDeliveryUser.fullName,
      );

      // Recharger les données
      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la réassignation: $e');
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
final deliveryAdminExistingProvider = StateNotifierProvider<
    DeliveryAdminExistingNotifier, DeliveryAdminExistingState>((ref) {
  return DeliveryAdminExistingNotifier();
});

// Provider pour les livreurs disponibles
final availableDeliveryUsersProvider = Provider<List<DeliveryUser>>((ref) {
  final state = ref.watch(deliveryAdminExistingProvider);
  return state.availableDeliveryUsers;
});

// Provider pour les commandes restaurant en attente
final pendingRestaurantOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryAdminExistingProvider);
  return state.pendingRestaurantOrders;
});

// Provider pour les colis en attente
final pendingParcelOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryAdminExistingProvider);
  return state.pendingParcelOrders;
});

// Provider pour les commandes restaurant assignées
final assignedRestaurantOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryAdminExistingProvider);
  return state.assignedRestaurantOrders;
});

// Provider pour les colis assignés
final assignedParcelOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryAdminExistingProvider);
  return state.assignedParcelOrders;
});
