import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'dart:async';
import '../../domain/entities/delivery_order.dart';
import '../../application/home_delivery_provider.dart';
import '../../data/services/delivery_location_service.dart';

class DeliveryNavigationPage extends ConsumerStatefulWidget {
  final DeliveryOrder order;

  const DeliveryNavigationPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  ConsumerState<DeliveryNavigationPage> createState() =>
      _DeliveryNavigationPageState();
}

class _DeliveryNavigationPageState extends ConsumerState<DeliveryNavigationPage>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _isDeliveryStarted = false;
  bool _isNavigating = false;
  bool _showOrderInfo = true;
  bool _isNearDestination = false;

  // Suivi de position
  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationTimer;
  LatLng? _destination;

  // Animations
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser les animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _initializeMap();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _positionSubscription?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  // Démarrer le suivi de position
  void _startLocationTracking() {
    if (_destination == null) return;

    // Vérifier la position toutes les 10 secondes
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _checkDistanceToDestination();
    });

    // Suivi en temps réel (optionnel, plus précis mais consomme plus de batterie)
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mettre à jour tous les 10 mètres
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _checkDistanceToDestination();
    });
  }

  // Vérifier la distance à la destination
  void _checkDistanceToDestination() async {
    if (_currentPosition == null || _destination == null) return;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _destination!.latitude,
      _destination!.longitude,
    );

    print('📍 Distance à destination: ${distance.toStringAsFixed(0)} mètres');

    // Si on est à moins de 50 mètres de la destination
    if (distance < 50 && !_isNearDestination) {
      setState(() {
        _isNearDestination = true;
      });

      // Afficher une notification
      _showArrivalNotification();

      // Envoyer une notification locale
      _sendLocalNotification();
    }
  }

  // Notification d'arrivée à destination
  void _showArrivalNotification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Arrivée à destination !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous êtes arrivé chez ${widget.order.customerName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'N\'oubliez pas de :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Livrer la commande'),
              ],
            ),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Cliquer sur "Terminer"'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeDelivery();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Terminer la livraison'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog('Permission de localisation refusée');
          return;
        }
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Créer les marqueurs et l'itinéraire
      await _createMapElements();

      // Démarrer les animations
      _slideController.forward();
      _pulseController.repeat(reverse: true);
    } catch (e) {
      print('❌ Erreur initialisation carte: $e');
      _showErrorDialog('Erreur lors du chargement de la carte');
    }
  }

  Future<void> _createMapElements() async {
    if (_currentPosition == null) return;

    _markers.clear();
    _polylines.clear();

    // Marqueur position actuelle
    _markers.add(
      Marker(
        markerId: const MarkerId('current_position'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: const InfoWindow(
          title: 'Votre position',
          snippet: 'Position actuelle',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Récupérer les vraies coordonnées de destination depuis Firestore
    LatLng destination;

    try {
      // Essayer de récupérer les coordonnées depuis Firestore
      final coords =
          await DeliveryLocationService.getOrderDestinationCoordinates(
              widget.order.id);

      if (coords != null) {
        // Utiliser les vraies coordonnées de destination depuis Firestore
        destination = LatLng(coords['latitude']!, coords['longitude']!);
        print(
            '📍 Destination Firestore: ${destination.latitude}, ${destination.longitude}');
      } else if (widget.order.destinationLatitude != null &&
          widget.order.destinationLongitude != null) {
        // Fallback: utiliser les coordonnées de l'entité
        destination = LatLng(
          widget.order.destinationLatitude!,
          widget.order.destinationLongitude!,
        );
        print(
            '📍 Destination entité: ${destination.latitude}, ${destination.longitude}');
      } else {
        // Fallback: utiliser des coordonnées par défaut (Yamoussoukro)
        destination = LatLng(6.8270, -5.2890);
        print(
            '⚠️ Coordonnées par défaut utilisées: ${destination.latitude}, ${destination.longitude}');
      }
    } catch (e) {
      print('❌ Erreur récupération coordonnées: $e');
      // En cas d'erreur, utiliser des coordonnées par défaut
      destination = LatLng(6.8270, -5.2890);
      print(
          '⚠️ Coordonnées par défaut (erreur): ${destination.latitude}, ${destination.longitude}');
    }

    // Vérifier que les coordonnées sont valides
    if (destination.latitude == 0.0 && destination.longitude == 0.0) {
      destination = LatLng(6.8270, -5.2890);
      print(
          '⚠️ Coordonnées invalides détectées, utilisation par défaut: ${destination.latitude}, ${destination.longitude}');
    }

    // Sauvegarder la destination pour le suivi
    _destination = destination;

    print(
        '🎯 Création marqueur destination: ${destination.latitude}, ${destination.longitude}');
    print('🎯 Nombre de marqueurs avant: ${_markers.length}');

    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(
          title: widget.order.customerName,
          snippet: widget.order.customerAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        // Rendre le marqueur plus visible
        draggable: false,
        flat: false,
        anchor: Offset(0.5, 1.0),
        zIndex: 1000, // Priorité élevée
      ),
    );

    print('🎯 Nombre de marqueurs après: ${_markers.length}');
    print(
        '🎯 Marqueurs présents: ${_markers.map((m) => m.markerId.value).toList()}');

    // Créer un itinéraire réaliste avec des points intermédiaires
    final routePoints = _generateRoutePoints(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      destination,
    );

    // Itinéraire avec style professionnel
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 5,
        patterns: [PatternItem.dot, PatternItem.gap(8)],
        geodesic: true,
      ),
    );

    // Ajouter des marqueurs pour les points intermédiaires
    for (int i = 0; i < routePoints.length; i += 3) {
      // Tous les 3 points
      if (i > 0 && i < routePoints.length - 1) {
        _markers.add(
          Marker(
            markerId: MarkerId('waypoint_$i'),
            position: routePoints[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueYellow),
            infoWindow: InfoWindow(
              title: 'Point de passage ${i ~/ 3 + 1}',
              snippet: 'Étape intermédiaire',
            ),
          ),
        );
      }
    }

    setState(() {});

    // Animer la carte pour montrer l'itinéraire complet
    if (_mapController != null) {
      final bounds = _getBoundsForRoute(routePoints);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );

      // Forcer le rafraîchissement de la carte
      await Future.delayed(Duration(milliseconds: 500));
      _mapController!.moveCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }

    print('✅ Carte mise à jour avec ${_markers.length} marqueurs');
  }

  List<LatLng> _generateRoutePoints(LatLng start, LatLng end) {
    final points = <LatLng>[];

    // Point de départ
    points.add(start);

    // Calculer la distance et l'angle
    final latDiff = end.latitude - start.latitude;
    final lngDiff = end.longitude - start.longitude;
    final distance = sqrt(latDiff * latDiff + lngDiff * lngDiff);

    // Créer des points intermédiaires pour simuler un itinéraire réaliste
    final numPoints = 10;
    for (int i = 1; i < numPoints; i++) {
      final progress = i / numPoints;

      // Ajouter une légère courbe pour simuler un itinéraire routier
      final curveOffset = sin(progress * pi) * 0.001;

      final lat = start.latitude + (latDiff * progress) + curveOffset;
      final lng = start.longitude + (lngDiff * progress) + curveOffset;

      points.add(LatLng(lat, lng));
    }

    // Point d'arrivée
    points.add(end);

    return points;
  }

  LatLngBounds _getBoundsForRoute(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _startDelivery() async {
    try {
      // Animation de démarrage
      _pulseController.stop();

      // Démarrer la livraison dans le provider
      await ref.read(homeDeliveryProvider.notifier).startDelivery(widget.order);

      setState(() {
        _isDeliveryStarted = true;
      });

      // Démarrer le suivi de position
      _startLocationTracking();

      // Animation de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Livraison démarrée ! Suivi de position activé'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      print('❌ Erreur démarrage livraison: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _completeDelivery() async {
    try {
      // Terminer la livraison dans le provider
      await ref
          .read(homeDeliveryProvider.notifier)
          .completeDelivery(widget.order);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Livraison terminée !'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Retourner à la page précédente
      Navigator.of(context).pop();
    } catch (e) {
      print('❌ Erreur fin livraison: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Erreur: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _openGoogleMapsNavigation() async {
    try {
      if (_currentPosition == null) {
        throw 'Position actuelle non disponible';
      }

      if (_destination == null) {
        throw 'Destination non disponible';
      }

      // Utiliser les vraies coordonnées de destination
      final destinationLat = _destination!.latitude;
      final destinationLng = _destination!.longitude;

      print('📍 Navigation vers: $destinationLat, $destinationLng');
      print('📍 Adresse client: ${widget.order.customerAddress}');
      print('📍 Nom client: ${widget.order.customerName}');

      // URL pour Google Maps Navigation
      final url = 'google.navigation:q=$destinationLat,$destinationLng';

      print('🌐 Tentative d\'ouverture: $url');

      // Vérifier si l'URL peut être lancée
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );

        setState(() {
          _isNavigating = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation Google Maps ouverte !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Fallback vers Google Maps web
        final webUrl =
            'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng';
        print('🌐 Fallback vers web: $webUrl');

        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(
            Uri.parse(webUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Impossible d\'ouvrir Google Maps';
        }
      }
    } catch (e) {
      print('❌ Erreur ouverture navigation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour afficher les coordonnées de destination
  String _getDestinationCoordinatesText() {
    if (_destination != null) {
      return '${_destination!.latitude.toStringAsFixed(6)}, ${_destination!.longitude.toStringAsFixed(6)}';
    }
    return 'Coordonnées non disponibles';
  }

  // Méthode pour calculer la distance à la destination
  String _getDistanceToDestination() {
    if (_currentPosition == null || _destination == null) {
      return 'Calcul...';
    }

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _destination!.latitude,
      _destination!.longitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  // Envoyer une notification locale
  void _sendLocalNotification() {
    // TODO: Implémenter avec flutter_local_notifications
    print('🔔 Notification: Vous êtes arrivé à destination !');

    // Pour l'instant, on utilise juste un SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notification_important, color: Colors.white),
            SizedBox(width: 8),
            Text('Vous êtes arrivé à destination !'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Terminer',
          textColor: Colors.white,
          onPressed: () {
            _completeDelivery();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte en arrière-plan
          _isLoading
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.shade50,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.map,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Chargement de la carte...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Préparation de votre itinéraire',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _currentPosition == null
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.red.shade50,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Position non disponible',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Vérifiez vos permissions de localisation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _initializeMap,
                              icon: Icon(Icons.refresh),
                              label: Text('Réessayer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        _createMapElements();
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 15.0,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: true,
                      mapType: MapType.normal,
                    ),

          // En-tête avec infos de la commande
          if (_showOrderInfo)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.arrow_back),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Commande #${widget.order.id}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.order.customerName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isDeliveryStarted
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _isDeliveryStarted
                                          ? 1.0
                                          : _pulseAnimation.value,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 6),
                                Text(
                                  _isDeliveryStarted ? 'En cours' : 'Prêt',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Destination',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    widget.order.customerAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (_isDeliveryStarted &&
                                      _destination != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'Distance: ${_getDistanceToDestination()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _isNearDestination
                                            ? Colors.green
                                            : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Coords: ${_getDestinationCoordinatesText()}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Boutons d'action en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Bouton navigation
                    if (_isDeliveryStarted) ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              _isNavigating ? null : _openGoogleMapsNavigation,
                          icon: _isNavigating
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(Icons.navigation),
                          label: Text(_isNavigating
                              ? 'Navigation ouverte...'
                              : 'Ouvrir Navigation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Boutons d'action
                    Row(
                      children: [
                        if (!_isDeliveryStarted) ...[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _startDelivery,
                                icon: Icon(Icons.play_arrow),
                                label: Text('Démarrer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _completeDelivery,
                                icon: Icon(Icons.check),
                                label: Text('Terminer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close),
                            label: Text('Fermer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bouton de navigation
          Positioned(
            bottom: 120,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton de débogage (temporaire)
                  if (_destination != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Coordonnées de destination'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Latitude: ${_destination!.latitude}'),
                                      Text(
                                          'Longitude: ${_destination!.longitude}'),
                                      SizedBox(height: 8),
                                      Text(
                                          'Client: ${widget.order.customerName}'),
                                      Text(
                                          'Adresse: ${widget.order.customerAddress}'),
                                      SizedBox(height: 8),
                                      Text('Marqueurs: ${_markers.length}'),
                                      Text(
                                          'Marqueurs IDs: ${_markers.map((m) => m.markerId.value).toList()}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Fermer'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _createMapElements();
                                      },
                                      child: Text('Rafraîchir'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(Icons.info),
                            tooltip: 'Voir les coordonnées',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _createMapElements();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Carte rafraîchie'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: Icon(Icons.refresh),
                            tooltip: 'Rafraîchir la carte',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.orange.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bouton de navigation
                  ElevatedButton.icon(
                    onPressed: _isNavigating ? null : _openGoogleMapsNavigation,
                    icon: _isNavigating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.navigation),
                    label: Text(_isNavigating ? 'Ouverture...' : 'Naviguer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Légende de la carte
          Positioned(
            top: 200,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Votre position',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Destination',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Points de passage',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distance estimée: ~1.2 km',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Temps estimé: ~5 min',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton toggle info
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showOrderInfo = !_showOrderInfo;
                  });
                },
                icon: Icon(
                  _showOrderInfo ? Icons.visibility_off : Icons.visibility,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
