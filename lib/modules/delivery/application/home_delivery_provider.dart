import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/delivery_existing_service.dart';
import '../domain/entities/delivery_user.dart';
import '../domain/entities/delivery_order.dart';
import '../../../core/local_storage_factory.dart';
import 'dart:convert';

class HomeDeliveryState {
  final DeliveryUser? currentUser;
  final List<DeliveryOrder> assignedOrders;
  final List<DeliveryOrder> completedOrders;
  final double todayEarnings;
  final bool isLoading;
  final String? error;

  const HomeDeliveryState({
    this.currentUser,
    this.assignedOrders = const [],
    this.completedOrders = const [],
    this.todayEarnings = 0.0,
    this.isLoading = false,
    this.error,
  });

  HomeDeliveryState copyWith({
    DeliveryUser? currentUser,
    List<DeliveryOrder>? assignedOrders,
    List<DeliveryOrder>? completedOrders,
    double? todayEarnings,
    bool? isLoading,
    String? error,
  }) {
    return HomeDeliveryState(
      currentUser: currentUser ?? this.currentUser,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeDeliveryNotifier extends StateNotifier<HomeDeliveryState> {
  HomeDeliveryNotifier() : super(const HomeDeliveryState()) {
    _initializeDeliveryUser();
  }

  // Initialiser le livreur connecté
  Future<void> _initializeDeliveryUser() async {
    try {
      state = state.copyWith(isLoading: true);

      final userDetailsJson = LocalStorageFactory().getUserDetails();
      print('User details JSON: $userDetailsJson');

      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
      print('User details parsed: $userDetails');

      final phoneNumber = userDetails['phoneNumber'] ?? '';
      print('Phone number extracted: "$phoneNumber"');

      if (phoneNumber.isNotEmpty) {
        print('Recherche du livreur avec le numéro: $phoneNumber');
        final deliveryUser =
            await DeliveryExistingService.getDeliveryUserByPhone(phoneNumber);
        if (deliveryUser != null) {
          print('Livreur trouvé: ${deliveryUser.fullName}');
          state = state.copyWith(currentUser: deliveryUser);
          await _loadAllData(phoneNumber);
        } else {
          print('Livreur non trouvé pour le numéro: $phoneNumber');
          state =
              state.copyWith(error: 'Utilisateur non trouvé ou non livreur');
        }
      } else {
        print('Numéro de téléphone vide');
        state = state.copyWith(error: 'Numéro de téléphone non trouvé');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      state = state.copyWith(error: 'Erreur lors de l\'initialisation: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Charger toutes les données
  Future<void> _loadAllData(String phoneNumber) async {
    try {
      final restaurantOrders =
          await DeliveryExistingService.getRestaurantOrdersForDeliveryUser(
              phoneNumber);
      final parcelOrders =
          await DeliveryExistingService.getParcelOrdersForDeliveryUser(
              phoneNumber);

      // Combiner toutes les commandes assignées
      final allAssignedOrders = [...restaurantOrders, ...parcelOrders];

      // Séparer les commandes en cours et terminées
      final assignedOrders = allAssignedOrders
          .where((order) =>
              order.status == DeliveryStatus.reception ||
              order.status == DeliveryStatus.enRoute)
          .toList();

      final completedOrders = allAssignedOrders
          .where((order) => order.status == DeliveryStatus.livre)
          .toList();

      final todayEarnings =
          await DeliveryExistingService.getTodayEarnings(phoneNumber);

      state = state.copyWith(
        assignedOrders: assignedOrders,
        completedOrders: completedOrders,
        todayEarnings: todayEarnings,
      );
    } catch (e) {
      state =
          state.copyWith(error: 'Erreur lors du chargement des données: $e');
    }
  }

  // Mettre à jour la disponibilité
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      // Ne pas mettre isLoading à true pour éviter le rechargement de la page
      final phoneNumber = state.currentUser?.phoneNumber;
      final userId = state.currentUser?.id;
      print('Current user: ${state.currentUser?.fullName}');
      print('Current user phoneNumber: "${state.currentUser?.phoneNumber}"');
      print('Current user id: "${state.currentUser?.id}"');

      // Utiliser phoneNumber ou id comme fallback
      final phoneToUse = (phoneNumber != null && phoneNumber.isNotEmpty)
          ? phoneNumber
          : userId;

      if (phoneToUse != null && phoneToUse.isNotEmpty) {
        print(
            'Mise à jour de la disponibilité pour: $phoneToUse, disponible: $isAvailable');

        // Mettre à jour l'état local immédiatement pour une réponse instantanée
        if (state.currentUser != null) {
          final updatedUser =
              state.currentUser!.copyWith(isAvailable: isAvailable);
          state = state.copyWith(currentUser: updatedUser);
        }

        // Mettre à jour Firestore en arrière-plan
        await DeliveryExistingService.updateDeliveryUserAvailability(
            phoneToUse, isAvailable);

        print('Disponibilité mise à jour avec succès');
      } else {
        print(
            'Erreur: Numéro de téléphone invalide: phoneNumber=$phoneNumber, id=$userId');
        state = state.copyWith(error: 'Erreur: Numéro de téléphone invalide');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la disponibilité: $e');
      // En cas d'erreur, remettre l'ancienne valeur
      if (state.currentUser != null) {
        final updatedUser =
            state.currentUser!.copyWith(isAvailable: !isAvailable);
        state = state.copyWith(currentUser: updatedUser);
      }
      state = state.copyWith(
          error: 'Erreur lors de la mise à jour de la disponibilité: $e');
    }
  }

  // Démarrer une livraison
  Future<void> startDelivery(DeliveryOrder order) async {
    try {
      state = state.copyWith(isLoading: true);

      if (order.type == DeliveryType.restaurant) {
        await DeliveryExistingService.updateRestaurantOrderStatus(
            order.id, DeliveryStatus.enRoute);
      } else {
        await DeliveryExistingService.updateParcelStatus(
            order.id, DeliveryStatus.enRoute);
      }

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

      if (order.type == DeliveryType.restaurant) {
        await DeliveryExistingService.updateRestaurantOrderStatus(
            order.id, DeliveryStatus.livre);
      } else {
        await DeliveryExistingService.updateParcelStatus(
            order.id, DeliveryStatus.livre);
      }

      // Recharger les données
      final phoneNumber = state.currentUser?.phoneNumber;
      if (phoneNumber != null) {
        await _loadAllData(phoneNumber);
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la finalisation de la livraison: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Marquer une livraison comme échouée
  Future<void> failDelivery(DeliveryOrder order) async {
    try {
      state = state.copyWith(isLoading: true);

      if (order.type == DeliveryType.restaurant) {
        await DeliveryExistingService.updateRestaurantOrderStatus(
            order.id, DeliveryStatus.nonLivre);
      } else {
        await DeliveryExistingService.updateParcelStatus(
            order.id, DeliveryStatus.nonLivre);
      }

      // Recharger les données
      final phoneNumber = state.currentUser?.phoneNumber;
      if (phoneNumber != null) {
        await _loadAllData(phoneNumber);
      }
    } catch (e) {
      state = state.copyWith(
          error: 'Erreur lors de la marque de la livraison comme échouée: $e');
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
final homeDeliveryProvider =
    StateNotifierProvider<HomeDeliveryNotifier, HomeDeliveryState>((ref) {
  return HomeDeliveryNotifier();
});

// Provider pour les commandes assignées
final assignedOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(homeDeliveryProvider);
  return state.assignedOrders;
});

// Provider pour l'historique
final completedOrdersProvider = Provider<List<DeliveryOrder>>((ref) {
  final state = ref.watch(homeDeliveryProvider);
  return state.completedOrders;
});

// Provider pour le livreur actuel
final currentDeliveryUserProvider = Provider<DeliveryUser?>((ref) {
  final state = ref.watch(homeDeliveryProvider);
  return state.currentUser;
});
