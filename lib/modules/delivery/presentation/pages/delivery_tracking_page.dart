import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../application/delivery_tracking_provider.dart';
import '../../application/delivery_location_provider.dart';

class DeliveryTrackingPage extends ConsumerStatefulWidget {
  final String orderId;
  final String clientAddress;
  final double clientLatitude;
  final double clientLongitude;

  const DeliveryTrackingPage({
    Key? key,
    required this.orderId,
    required this.clientAddress,
    required this.clientLatitude,
    required this.clientLongitude,
  }) : super(key: key);

  @override
  ConsumerState<DeliveryTrackingPage> createState() =>
      _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends ConsumerState<DeliveryTrackingPage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _updateTimer;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Position simulée du livreur (pour la démo) - Yamoussoukro
  LatLng _driverPosition = const LatLng(6.8270, -5.2890); // Yamoussoukro

  // Position par défaut de Yamoussoukro
  static const LatLng yamoussoukroPosition = LatLng(6.8270, -5.2890);

  // Position statique du livreur (pas de mouvement)
  static const LatLng staticDriverPosition = LatLng(6.8270, -5.2890);

  // Position actuelle du client (dynamique)
  LatLng? _clientCurrentPosition;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupMap();
    // Désactiver la simulation sur un vrai téléphone
    // _simulateDriverMovement();

    // Obtenir la vraie position du client
    _getClientCurrentPosition();

    // Démarrer le tracking avec la vraie position du livreur
    Future.microtask(() {
      _startTracking();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    // Ne pas disposer le contrôleur de carte ici pour éviter l'erreur
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'assurer que la carte est correctement initialisée
    if (_mapController == null) {
      Future.microtask(() {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  Future<void> _startTracking() async {
    try {
      await ref
          .read(deliveryTrackingProvider.notifier)
          .startTracking(widget.orderId);
    } catch (e) {
      print('Erreur lors du démarrage du suivi: $e');
    }
  }

  // Obtenir la vraie position du téléphone
  Future<Position?> _getCurrentLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      // Obtenir la position actuelle
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  void _getClientCurrentPosition() async {
    final position = await _getCurrentLocation();
    if (position != null) {
      _clientCurrentPosition = LatLng(position.latitude, position.longitude);
    }
  }

  void _setupMap() {
    _createMarkers();
    _createRoute();

    // Mettre à jour la carte toutes les 10 secondes avec la vraie position
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _updateMapWithRealPosition();
      }
    });
  }

  // Mettre à jour la carte avec la vraie position du livreur
  void _updateMapWithRealPosition() async {
    final trackingState = ref.read(deliveryTrackingProvider);
    final locationNotifier = ref.read(deliveryLocationProvider.notifier);

    if (trackingState.deliveryLocation != null) {
      // Récupérer les coordonnées de destination depuis Firestore
      final destinationCoords =
          await locationNotifier.getOrderDestinationCoordinates(widget.orderId);

      setState(() {
        _createMarkersWithRealPosition(
            trackingState.deliveryLocation!, destinationCoords);
        _createRouteWithRealPosition(
            trackingState.deliveryLocation!, destinationCoords);
      });
    }
  }

  void _createMarkersWithRealPosition(DeliveryLocation deliveryLocation,
      Map<String, double>? destinationCoords) {
    _markers.clear();

    // Utiliser la position actuelle du client si disponible, sinon la position par défaut
    final clientPosition = _clientCurrentPosition ??
        LatLng(widget.clientLatitude, widget.clientLongitude);

    // Marqueur du client (maison) - utiliser les coordonnées de destination si disponibles
    final destinationPosition = destinationCoords != null
        ? LatLng(
            destinationCoords['latitude']!, destinationCoords['longitude']!)
        : clientPosition;

    _markers.add(
      Marker(
        markerId: const MarkerId('client'),
        position: destinationPosition,
        infoWindow: InfoWindow(
          title: 'Adresse de livraison',
          snippet: widget.clientAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Marqueur du livreur avec sa vraie position
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(deliveryLocation.latitude, deliveryLocation.longitude),
        infoWindow: InfoWindow(
          title: 'Livreur en route',
          snippet: 'Distance: ${_formatDistance(
            LatLng(deliveryLocation.latitude, deliveryLocation.longitude),
            destinationPosition,
          )}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _createRouteWithRealPosition(DeliveryLocation deliveryLocation,
      Map<String, double>? destinationCoords) {
    _polylines.clear();

    // Utiliser la position actuelle du client si disponible, sinon la position par défaut
    final clientPosition = _clientCurrentPosition ??
        LatLng(widget.clientLatitude, widget.clientLongitude);

    // Utiliser les coordonnées de destination si disponibles
    final destinationPosition = destinationCoords != null
        ? LatLng(
            destinationCoords['latitude']!, destinationCoords['longitude']!)
        : clientPosition;

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: [
          LatLng(deliveryLocation.latitude, deliveryLocation.longitude),
          destinationPosition,
        ],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ),
    );
  }

  void _createMarkers() {
    _markers.clear();

    // Utiliser la position actuelle du client si disponible, sinon la position par défaut
    final clientPosition = _clientCurrentPosition ??
        LatLng(widget.clientLatitude, widget.clientLongitude);

    // Marqueur du client (maison)
    _markers.add(
      Marker(
        markerId: const MarkerId('client'),
        position: clientPosition,
        infoWindow: InfoWindow(
          title: 'Votre adresse',
          snippet: widget.clientAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Marqueur du livreur (voiture) - Position statique
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: staticDriverPosition,
        infoWindow: InfoWindow(
          title: 'Livreur en route',
          snippet:
              'Distance: ${_formatDistance(staticDriverPosition, clientPosition)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _createRoute() {
    _polylines.clear();

    // Utiliser la position actuelle du client si disponible, sinon la position par défaut
    final clientPosition = _clientCurrentPosition ??
        LatLng(widget.clientLatitude, widget.clientLongitude);

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: [
          staticDriverPosition,
          clientPosition,
        ],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ),
    );
  }

  void _updateMap() {
    if (mounted) {
      setState(() {
        _createMarkers();
        _createRoute();
      });

      // Centrer la carte sur le livreur avec animation
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(staticDriverPosition),
      );
    }
  }

  String _formatDistance(LatLng position, LatLng clientPosition) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      clientPosition.latitude,
      clientPosition.longitude,
    );

    if (distance < 1000) {
      return '${distance.round()} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  String _formatEstimatedTime(LatLng position, LatLng clientPosition) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      clientPosition.latitude,
      clientPosition.longitude,
    );

    // Vitesse moyenne estimée : 30 km/h en ville
    final speedKmh = 30.0;
    final speedMs = speedKmh * 1000 / 3600; // Conversion en m/s
    final timeSeconds = distance / speedMs;
    final timeMinutes = (timeSeconds / 60).round();

    if (timeMinutes < 1) {
      return 'Moins de 1 min';
    } else if (timeMinutes < 60) {
      return '$timeMinutes min';
    } else {
      final hours = timeMinutes ~/ 60;
      final minutes = timeMinutes % 60;
      return '${hours}h ${minutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(deliveryTrackingProvider);
    bool _mapError = false;

    return Scaffold(
      body: Stack(
        children: [
          // Carte Google Maps avec gestion d'erreur
          _mapError
              ? Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carte temporairement indisponible',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Suivi en cours depuis Yamoussoukro',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target:
                        LatLng(widget.clientLatitude, widget.clientLongitude),
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (position) {
                    // Gérer les erreurs de carte
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                ),

          // Bouton retour personnalisé
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bouton de partage
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _switchToSimpleView(),
                    tooltip: 'Version simplifiée',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareTracking(),
                  ),
                ),
              ],
            ),
          ),

          // Panneau d'informations en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Poignée de glissement
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête avec statut
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.delivery_dining,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getStatusText(trackingState.orderStatus),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Commande #${widget.orderId.substring(0, 8)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Informations de distance et temps
                          if (trackingState.orderStatus == 'enRoute') ...[
                            FutureBuilder<Map<String, double>?>(
                              future: ref
                                  .read(deliveryLocationProvider.notifier)
                                  .getOrderDestinationCoordinates(
                                      widget.orderId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildInfoRow(
                                    Icons.location_on,
                                    'Distance',
                                    'Calcul...',
                                    Colors.blue,
                                  );
                                }

                                final destinationCoords = snapshot.data;
                                final destinationPosition =
                                    destinationCoords != null
                                        ? LatLng(destinationCoords['latitude']!,
                                            destinationCoords['longitude']!)
                                        : (_clientCurrentPosition ??
                                            LatLng(widget.clientLatitude,
                                                widget.clientLongitude));

                                return Column(
                                  children: [
                                    _buildInfoRow(
                                      Icons.location_on,
                                      'Distance',
                                      trackingState.deliveryLocation != null
                                          ? _formatDistance(
                                              LatLng(
                                                trackingState
                                                    .deliveryLocation!.latitude,
                                                trackingState.deliveryLocation!
                                                    .longitude,
                                              ),
                                              destinationPosition,
                                            )
                                          : 'Calcul...',
                                      Colors.blue,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.access_time,
                                      'Arrivée estimée',
                                      trackingState.deliveryLocation != null
                                          ? _formatEstimatedTime(
                                              LatLng(
                                                trackingState
                                                    .deliveryLocation!.latitude,
                                                trackingState.deliveryLocation!
                                                    .longitude,
                                              ),
                                              destinationPosition,
                                            )
                                          : 'Calcul...',
                                      Colors.orange,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      Icons.person,
                                      'Livreur',
                                      'Mohamed D.',
                                      Colors.green,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ] else if (trackingState.orderStatus ==
                              'reception') ...[
                            _buildInfoRow(
                              Icons.restaurant,
                              'Statut',
                              'En réception',
                              Colors.orange,
                            ),
                          ] else if (trackingState.orderStatus == 'livre') ...[
                            _buildInfoRow(
                              Icons.check_circle,
                              'Statut',
                              'Livré avec succès',
                              Colors.green,
                            ),
                          ] else if (trackingState.orderStatus ==
                              'nonLivre') ...[
                            _buildInfoRow(
                              Icons.error,
                              'Statut',
                              'Non livré',
                              Colors.red,
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Boutons d'action
                          if (trackingState.orderStatus == 'enRoute') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _callDeliveryPerson(),
                                    icon: const Icon(Icons.phone),
                                    label: const Text('Appeler'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _shareTracking(),
                                    icon: const Icon(Icons.share),
                                    label: const Text('Partager'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'reception':
        return 'En réception';
      case 'assigned':
        return 'Assigné à un livreur';
      case 'enRoute':
        return 'Livreur en route';
      case 'livre':
        return 'Livré';
      case 'nonLivre':
        return 'Non livré';
      default:
        return 'En attente';
    }
  }

  void _callDeliveryPerson() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appeler le livreur'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareTracking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager le suivi'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _switchToSimpleView() {

  }
}
