import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/delivery_service.dart';
import '../domain/entities/delivery_user.dart';
import '../domain/entities/delivery_order.dart';
import '../../../core/local_storage_factory.dart';
import 'dart:convert';

class DeliveryState {
  final DeliveryUser? currentUser;
  final List<DeliveryOrder> pendingOrders;
  final List<DeliveryOrder> assignedOrders;
  final List<DeliveryOrder> completedOrders;
  final double todayEarnings;
  final double weekEarnings;
  final bool isLoading;
  final String? error;

  const DeliveryState({
    this.currentUser,
    this.pendingOrders = const [],
    this.assignedOrders = const [],
    this.completedOrders = const [],
    this.todayEarnings = 0.0,
    this.weekEarnings = 0.0,
    this.isLoading = false,
    this.error,
  });

  DeliveryState copyWith({
    DeliveryUser? currentUser,
    List<DeliveryOrder>? pendingOrders,
    List<DeliveryOrder>? assignedOrders,
    List<DeliveryOrder>? completedOrders,
    double? todayEarnings,
    double? weekEarnings,
    bool? isLoading,
    String? error,
  }) {
    return DeliveryState(
      currentUser: currentUser ?? this.currentUser,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weekEarnings: weekEarnings ?? this.weekEarnings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  DeliveryNotifier() : super(const DeliveryState()) {
    _initializeDeliveryUser();
  }

  // Initialiser le livreur connecté
  Future<void> _initializeDeliveryUser() async {
    try {
      state = state.copyWith(isLoading: true);

      final userDetailsJson = LocalStorageFactory().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      if (phoneNumber.isNotEmpty) {
        final deliveryUser =
            await DeliveryService.getDeliveryUserByPhone(phoneNumber);
        if (deliveryUser != null) {
          state = state.copyWith(currentUser: deliveryUser);
          await _loadAllData(phoneNumber);
        } else {
          state =
              state.copyWith(error: 'Utilisateur non trouvé ou non livreur');
        }
      } else {
        state = state.copyWith(error: 'Numéro de téléphone non trouvé');
      }
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de l\'initialisation: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Charger toutes les données
  Future<void> _loadAllData(String phoneNumber) async {
    try {
      final pendingOrders = await DeliveryService.getPendingOrders();
      final assignedOrders =
          await DeliveryService.getOrdersForDeliveryUser(phoneNumber);
      final completedOrders =
          await DeliveryService.getDeliveryHistory(phoneNumber);
      final todayEarnings = await DeliveryService.getTodayEarnings(phoneNumber);
      final weekEarnings = await DeliveryService.getWeekEarnings(phoneNumber);

      state = state.copyWith(
        pendingOrders: pendingOrders,
        assignedOrders: assignedOrders,
        completedOrders: completedOrders,
        todayEarnings: todayEarnings,
        weekEarnings: weekEarnings,
      );
    } catch (e) {
      state =
          state.copyWith(error: 'Erreur lors du chargement des données: $e');
    }
  }

  // Mettre à jour la disponibilité
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      state = state.copyWith(isLoading: true);

      final phoneNumber = state.currentUser?.phoneNumber;
      if (phoneNumber != null) {
        await DeliveryService.updateDeliveryUserAvailability(
            phoneNumber, isAvailable);

        // Mettre à jour l'état local
        if (state.currentUser != null) {
          final updatedUser =
              state.currentUser!.copyWith(isAvailable: isAvailable);
          state = state.copyWith(currentUser: updatedUser);
        }
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la mise à jour de la disponibilité: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Accepter une commande
  Future<void> acceptOrder(DeliveryOrder order) async {
    try {
      state = state.copyWith(isLoading: true);

      final phoneNumber = state.currentUser?.phoneNumber;
      final deliveryName = state.currentUser?.fullName;

      if (phoneNumber != null && deliveryName != null) {
        await DeliveryService.assignOrderToDeliveryUser(
          order.id,
          phoneNumber,
          deliveryName,
        );

        // Recharger les données
        await _loadAllData(phoneNumber);
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de l\'acceptation de la commande: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Démarrer une livraison
  Future<void> startDelivery(DeliveryOrder order) async {
    try {
      state = state.copyWith(isLoading: true);

      await DeliveryService.updateOrderStatus(
          order.id, DeliveryStatus.reception);

      // Recharger les données
      final phoneNumber = state.currentUser?.phoneNumber;
      if (phoneNumber != null) {
        await _loadAllData(phoneNumber);
      }
    } catch (e) {
      state =
          state.copyWith(error: 'Erreur lors du démarrage de la livraison: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Terminer une livraison
  Future<void> completeDelivery(DeliveryOrder order) async {
    try {
      state = state.copyWith(isLoading: true);

      final phoneNumber = state.currentUser?.phoneNumber;
      if (phoneNumber != null) {
        await DeliveryService.completeOrder(
          order.id,
          phoneNumber,
          order.deliveryFee,
        );

        // Recharger les données
        await _loadAllData(phoneNumber);
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la finalisation de la livraison: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Rafraîchir les données
  Future<void> refreshData() async {
    final phoneNumber = state.currentUser?.phoneNumber;
    if (phoneNumber != null) {
      await _loadAllData(phoneNumber);
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  return DeliveryNotifier();
});

// Provider pour les commandes en attente
final pendingOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryProvider);
  return state.pendingOrders;
});

// Provider pour les commandes assignées
final assignedOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryProvider);
  return state.assignedOrders;
});

// Provider pour l'historique
final completedOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(deliveryProvider);
  return state.completedOrders;
});

// Provider pour le livreur actuel
final currentDeliveryUserProvider = Provider<DeliveryUser?>((ref) {
  final state = ref.watch(deliveryProvider);
  return state.currentUser;
});
