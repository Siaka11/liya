import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/storage/local_storage_factory.dart';
import '../data/services/delivery_location_service.dart';
import '../domain/entities/delivery_user.dart';

class DeliveryLocationState {
  final bool isLoading;
  final bool isOnline;
  final bool isSharingLocation;
  final String? error;
  final List<DeliveryUser> availableDeliveryUsers;
  final DeliveryUser? currentDeliveryUser;
  final Position? currentPosition;
  final List<Map<String, dynamic>> assignedOrders;

  const DeliveryLocationState({
    this.isLoading = false,
    this.isOnline = false,
    this.isSharingLocation = false,
    this.error,
    this.availableDeliveryUsers = const [],
    this.currentDeliveryUser,
    this.currentPosition,
    this.assignedOrders = const [],
  });

  DeliveryLocationState copyWith({
    bool? isLoading,
    bool? isOnline,
    bool? isSharingLocation,
    String? error,
    List<DeliveryUser>? availableDeliveryUsers,
    DeliveryUser? currentDeliveryUser,
    Position? currentPosition,
    List<Map<String, dynamic>>? assignedOrders,
  }) {
    return DeliveryLocationState(
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      isSharingLocation: isSharingLocation ?? this.isSharingLocation,
      error: error,
      availableDeliveryUsers:
          availableDeliveryUsers ?? this.availableDeliveryUsers,
      currentDeliveryUser: currentDeliveryUser ?? this.currentDeliveryUser,
      currentPosition: currentPosition ?? this.currentPosition,
      assignedOrders: assignedOrders ?? this.assignedOrders,
    );
  }
}

class DeliveryLocationNotifier extends StateNotifier<DeliveryLocationState> {
  DeliveryLocationNotifier() : super(const DeliveryLocationState()) {
    // Ne pas initialiser automatiquement, laisser la page gérer
    print('🚀 DeliveryLocationNotifier créé');
  }

  // Initialiser les données du livreur connecté
  Future<void> _initializeDeliveryUser() async {
    try {
      // Récupérer directement les détails utilisateur
      final userDetails = await LocalStorageFactory().getUserDetails();
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      print('🔍 userDetails: $userDetails');
      print('📱 Numéro extrait: $phoneNumber');

      if (phoneNumber.isNotEmpty) {
        // Vérifier le statut actuel du livreur
        final isOnline = await _checkDriverOnlineStatus(phoneNumber);
        state = state.copyWith(
          isOnline: isOnline,
          isSharingLocation: isOnline,
        );

        // Charger automatiquement les commandes assignées au démarrage
        await loadAssignedOrders();
      }
    } catch (e) {
      print('❌ Erreur initialisation livreur: $e');
    }
  }

  // Vérifier si le livreur est en ligne
  Future<bool> _checkDriverOnlineStatus(String phoneNumber) async {
    try {
      // Chercher dans orders pour voir si le livreur a des commandes actives
      final ordersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('delivery_phone_number', isEqualTo: phoneNumber)
          .where('status', whereIn: ['enRoute', 'reception']).get();

      print(
          '🔍 Livreur $phoneNumber - Commandes actives: ${ordersQuery.docs.length}');

      // Si le livreur a des commandes actives, il est considéré comme en ligne
      return ordersQuery.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erreur vérification statut: $e');
      return false;
    }
  }

  // Connecter le livreur (disponible)
  Future<bool> connectDriver() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Récupérer directement les détails utilisateur
      final userDetails = await LocalStorageFactory().getUserDetails();
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      if (phoneNumber.isEmpty) {
        state = state.copyWith(
          error: 'Numéro de téléphone non trouvé',
          isLoading: false,
        );
        return false;
      }

      print('🔵 Connexion du livreur: $phoneNumber');

      // Connecter le livreur (disponible mais pas en course)
      await DeliveryLocationService.connectDeliveryUser(phoneNumber);

      // Démarrer la mise à jour automatique (mode disponible)
      print('🔄 Appel de startAutomaticLocationUpdate pour: $phoneNumber');
      DeliveryLocationService.startAutomaticLocationUpdate(phoneNumber);
      print('✅ startAutomaticLocationUpdate lancé');

      // Charger automatiquement les commandes assignées
      await loadAssignedOrders();

      state = state.copyWith(
        isOnline: true, // Disponible pour recevoir des commandes
        isSharingLocation: false, // Pas encore en course
        isLoading: false,
      );

      print('✅ Livreur connecté avec succès (disponible)');
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur connexion: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Activer le livreur (GO ONLINE)
  Future<bool> activateDriver() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Récupérer directement les détails utilisateur
      final userDetails = await LocalStorageFactory().getUserDetails();
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      if (phoneNumber.isEmpty) {
        state = state.copyWith(
          error: 'Numéro de téléphone non trouvé',
          isLoading: false,
        );
        return false;
      }

      print('🚀 Activation du livreur: $phoneNumber');

      // Activer le livreur
      final success =
          await DeliveryLocationService.activateDeliveryUser(phoneNumber);

      if (success) {
        // Démarrer UNIQUEMENT la mise à jour automatique (nouvelle méthode)
        print('🔄 Appel de startAutomaticLocationUpdate pour: $phoneNumber');
        DeliveryLocationService.startAutomaticLocationUpdate(phoneNumber);
        print('✅ startAutomaticLocationUpdate lancé');

        // Charger automatiquement les commandes assignées
        await loadAssignedOrders();

        state = state.copyWith(
          isOnline: true,
          isSharingLocation: true,
          isLoading: false,
        );

        print('✅ Livreur activé avec succès (en course)');
        return true;
      } else {
        state = state.copyWith(
          error: 'Échec de l\'activation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur activation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Désactiver le livreur (GO OFFLINE)
  Future<bool> deactivateDriver() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Récupérer directement les détails utilisateur
      final userDetails = await LocalStorageFactory().getUserDetails();
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      if (phoneNumber.isEmpty) {
        state = state.copyWith(
          error: 'Numéro de téléphone non trouvé',
          isLoading: false,
        );
        return false;
      }

      print('🛑 Désactivation du livreur: $phoneNumber');

      // Désactiver le livreur
      final success =
          await DeliveryLocationService.deactivateDeliveryUser(phoneNumber);

      if (success) {
        // Arrêter UNIQUEMENT la mise à jour automatique (nouvelle méthode)
        await DeliveryLocationService.stopAutomaticLocationUpdate(phoneNumber);

        // Charger automatiquement les commandes assignées
        await loadAssignedOrders();

        state = state.copyWith(
          isOnline: false,
          isSharingLocation: false,
          isLoading: false,
        );

        print('✅ Livreur désactivé avec succès');
        return true;
      } else {
        state = state.copyWith(
          error: 'Échec de la désactivation',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur désactivation: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Charger les commandes assignées au livreur
  Future<void> loadAssignedOrders() async {
    try {
      print('🔄 loadAssignedOrders() appelé');

      // Récupérer directement les détails utilisateur
      final userDetails = await LocalStorageFactory().getUserDetails();
      final phoneNumber = userDetails['phoneNumber'] ?? '';

      print('🔍 userDetails: $userDetails');
      print('📱 Numéro extrait: $phoneNumber');

      print('📱 Numéro du livreur connecté: $phoneNumber');

      if (phoneNumber.isEmpty) {
        print('❌ Aucun numéro de téléphone trouvé pour le livreur');
        return;
      }

      // Charger les commandes assignées directement depuis orders
      final assignedOrders =
          await DeliveryLocationService.getAssignedOrdersForDriver(phoneNumber);

      print('📦 Commandes assignées trouvées: ${assignedOrders.length}');

      // Afficher les détails de chaque commande
      for (int i = 0; i < assignedOrders.length; i++) {
        final order = assignedOrders[i];
        print(
            '📋 Commande $i: ID=${order['id']}, Status=${order['status']}, Type=${order['type']}, Delivery=${order['delivery_phone_number']}, Name=${order['delivery_name']}');
      }

      state = state.copyWith(
        assignedOrders: assignedOrders,
        isLoading: false,
      );

      print('✅ State mis à jour avec ${assignedOrders.length} commandes');
    } catch (e) {
      print('❌ Erreur loadAssignedOrders: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Mettre à jour avec les commandes de test
  void updateTestOrders(List<Map<String, dynamic>> testOrders) {
    print('🧪 Mise à jour avec ${testOrders.length} commandes de test');
    state = state.copyWith(
      assignedOrders: testOrders,
      isLoading: false,
    );
  }

  // Charger les livreurs disponibles
  Future<void> loadAvailableDeliveryUsers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('🔍 Chargement des livreurs disponibles...');
      final availableUsers =
          await DeliveryLocationService.getAvailableDeliveryUsers();

      state = state.copyWith(
        availableDeliveryUsers: availableUsers,
        isLoading: false,
      );

      print('✅ ${availableUsers.length} livreurs chargés');
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur chargement: $e',
        isLoading: false,
      );
    }
  }

  // Assigner une commande au livreur le plus proche
  Future<DeliveryUser?> assignOrderToNearestDriver(
    String orderId,
    double destinationLat,
    double destinationLon,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final assignedDriver =
          await DeliveryLocationService.assignOrderToNearestDriver(
        orderId,
        destinationLat,
        destinationLon,
      );

      if (assignedDriver != null) {
        // Recharger la liste des livreurs disponibles
        await loadAvailableDeliveryUsers();

        state = state.copyWith(isLoading: false);
        return assignedDriver;
      } else {
        state = state.copyWith(
          error: 'Aucun livreur disponible',
          isLoading: false,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur assignation: $e',
        isLoading: false,
      );
      return null;
    }
  }

  // Assigner une commande à un livreur spécifique
  Future<bool> assignOrderToSpecificDriver(
    String orderId,
    String driverPhoneNumber,
    double destinationLat,
    double destinationLon,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await DeliveryLocationService.assignOrderToSpecificDriver(
        orderId,
        driverPhoneNumber,
        destinationLat,
        destinationLon,
      );

      if (success) {
        // Recharger la liste des livreurs disponibles
        await loadAvailableDeliveryUsers();

        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          error: 'Échec de l\'assignation au livreur spécifique',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur assignation spécifique: $e',
        isLoading: false,
      );
      return false;
    }
  }

  // Récupérer les coordonnées de destination d'une commande
  Future<Map<String, double>?> getOrderDestinationCoordinates(
      String orderId) async {
    try {
      return await DeliveryLocationService.getOrderDestinationCoordinates(
          orderId);
    } catch (e) {
      print('❌ Erreur récupération coordonnées destination: $e');
      return null;
    }
  }

  // Récupérer la position actuelle du livreur
  Future<Map<String, double>?> getDriverCurrentPosition(
      String driverPhone) async {
    try {
      return await DeliveryLocationService.getDriverCurrentPosition(
          driverPhone);
    } catch (e) {
      print('❌ Erreur récupération position livreur: $e');
      return null;
    }
  }

  // Mettre à jour la position actuelle
  Future<void> updateCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(currentPosition: position);
    } catch (e) {
      print('❌ Erreur mise à jour position: $e');
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final deliveryLocationProvider =
    StateNotifierProvider<DeliveryLocationNotifier, DeliveryLocationState>(
  (ref) => DeliveryLocationNotifier(),
);
