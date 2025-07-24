import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeliveryTrackingProvider extends StateNotifier<DeliveryTrackingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<DocumentSnapshot>? _orderSubscription;
  Timer? _updateTimer;

  DeliveryTrackingProvider() : super(DeliveryTrackingState.initial());

  // Démarrer le suivi de la commande
  Future<void> startTracking(String orderId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Écouter les changements de la commande
      _orderSubscription = _firestore
          .collection('orders')
          .doc(orderId)
          .snapshots()
          .listen(_onOrderUpdate);

      // Écouter la position du livreur seulement si en route
      _startLocationTracking(orderId);

      state = state.copyWith(
        isLoading: false,
        orderId: orderId,
        isTracking: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du démarrage du suivi: $e',
      );
    }
  }

  // Arrêter le suivi
  void stopTracking() {
    _locationSubscription?.cancel();
    _orderSubscription?.cancel();
    _updateTimer?.cancel();

    state = DeliveryTrackingState.initial();
  }

  // Démarrer le suivi de localisation (pour le livreur)
  Future<void> _startLocationTracking(String orderId) async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission de localisation refusée');
        }
      }

      // Écouter la position en temps réel
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Mettre à jour tous les 10 mètres
        ),
      ).listen((Position position) {
        _updateDeliveryLocation(orderId, position);
      });
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur de localisation: $e',
      );
    }
  }

  // Mettre à jour la position du livreur
  Future<void> _updateDeliveryLocation(
      String orderId, Position position) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'deliveryLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur mise à jour position: $e');
    }
  }

  // Gérer les mises à jour de la commande
  void _onOrderUpdate(DocumentSnapshot snapshot) {
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;

    // Mettre à jour l'état avec les nouvelles données
    state = state.copyWith(
      orderStatus: data['status'] ?? 'reception',
      deliveryLocation: data['deliveryLocation'] != null
          ? DeliveryLocation(
              latitude: data['deliveryLocation']['latitude'],
              longitude: data['deliveryLocation']['longitude'],
              timestamp: data['deliveryLocation']['timestamp']?.toDate(),
            )
          : null,
      estimatedArrival: data['estimatedArrival']?.toDate(),
      deliveryNotes: data['deliveryNotes'] ?? '',
    );

    // Arrêter le suivi si la commande est livrée ou non livrée
    if (data['status'] == 'livre' || data['status'] == 'nonLivre') {
      stopTracking();
    }
  }

  // Calculer la distance entre le livreur et le client
  double calculateDistance(
      DeliveryLocation? deliveryLocation, DeliveryLocation clientLocation) {
    if (deliveryLocation == null) return -1;

    return Geolocator.distanceBetween(
      deliveryLocation.latitude,
      deliveryLocation.longitude,
      clientLocation.latitude,
      clientLocation.longitude,
    );
  }

  // Calculer le temps d'arrivée estimé
  Duration calculateEstimatedTime(double distanceInMeters) {
    // Vitesse moyenne estimée : 30 km/h en ville
    const averageSpeedKmH = 30.0;
    const averageSpeedMs = averageSpeedKmH * 1000 / 3600; // m/s

    final timeInSeconds = distanceInMeters / averageSpeedMs;
    return Duration(seconds: timeInSeconds.round());
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}

// État du suivi
class DeliveryTrackingState {
  final bool isLoading;
  final bool isTracking;
  final String? error;
  final String? orderId;
  final String orderStatus;
  final DeliveryLocation? deliveryLocation;
  final DateTime? estimatedArrival;
  final String deliveryNotes;

  const DeliveryTrackingState({
    this.isLoading = false,
    this.isTracking = false,
    this.error,
    this.orderId,
    this.orderStatus = 'reception',
    this.deliveryLocation,
    this.estimatedArrival,
    this.deliveryNotes = '',
  });

  factory DeliveryTrackingState.initial() => const DeliveryTrackingState();

  DeliveryTrackingState copyWith({
    bool? isLoading,
    bool? isTracking,
    String? error,
    String? orderId,
    String? orderStatus,
    DeliveryLocation? deliveryLocation,
    DateTime? estimatedArrival,
    String? deliveryNotes,
  }) {
    return DeliveryTrackingState(
      isLoading: isLoading ?? this.isLoading,
      isTracking: isTracking ?? this.isTracking,
      error: error ?? this.error,
      orderId: orderId ?? this.orderId,
      orderStatus: orderStatus ?? this.orderStatus,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }
}

// Modèle de localisation
class DeliveryLocation {
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });
}

// Provider
final deliveryTrackingProvider =
    StateNotifierProvider<DeliveryTrackingProvider, DeliveryTrackingState>(
  (ref) => DeliveryTrackingProvider(),
);
