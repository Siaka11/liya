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
import 'package:cloud_firestore/cloud_firestore.dart';

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
  LatLng? _currentPosition;
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

  Timer? _arrivalDetectionTimer;
  bool _hasArrived = false;
  bool _isCheckingArrival = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startArrivalDetection();
  }

  @override
  void dispose() {
    _arrivalDetectionTimer?.cancel();
    _positionSubscription?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  void _initializeLocation() async {
    try {
      // Demander les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permissions de localisation refusées');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permissions de localisation refusées définitivement');
        return;
      }

      // Récupérer la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Créer les éléments de la carte
      _createMapElements();

      // Démarrer le suivi de position
      _startLocationTracking();
    } catch (e) {
      print('❌ Erreur initialisation localisation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _startNavigation() async {
    if (_destination == null) return;

    setState(() {
      _isNavigating = true;
    });

    // Mettre à jour le statut de la commande
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({
        'status': 'enRoute',
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course démarrée!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Erreur démarrage course: $e');
    }
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
        _currentPosition = LatLng(position.latitude, position.longitude);
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

  void _startArrivalDetection() {
    _arrivalDetectionTimer =
        Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_hasArrived || _isCheckingArrival) return;

      _isCheckingArrival = true;

      try {
        // Récupérer la position actuelle
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (_destination != null) {
          // Calculer la distance jusqu'à la destination
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            _destination!.latitude,
            _destination!.longitude,
          );

          print(
              '📍 Distance jusqu\'à destination: ${distance.toStringAsFixed(2)}m');

          // Si on est à moins de 50 mètres de la destination
          if (distance <= 50 && !_hasArrived) {
            _hasArrived = true;
            _showArrivalDialog();
            timer.cancel();

            // Ne pas changer le statut ici, il restera "enRoute" jusqu'à confirmation
            print('🎯 Arrivée détectée à destination!');
          }
        }
      } catch (e) {
        print('❌ Erreur détection arrivée: $e');
      } finally {
        _isCheckingArrival = false;
      }
    });
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 8),
            Text('Arrivée à destination'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vous êtes arrivé à destination!'),
            SizedBox(height: 16),
            Text(
              'Client: ${widget.order.customerName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Adresse: ${widget.order.customerAddress}'),
            SizedBox(height: 16),
            Text(
              'Veuillez remettre la commande au client.',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeliveryCompletionDialog();
            },
            child: Text('Livraison terminée'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeliveryFailureDialog();
            },
            child: Text('Problème de livraison'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Livraison réussie'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('La commande a été livrée avec succès!'),
            SizedBox(height: 16),
            Text('Client: ${widget.order.customerName}'),
            Text('Montant: ${widget.order.totalAmount} FCFA'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _finalizeDelivery(true);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showDeliveryFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Problème de livraison'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quel est le problème?'),
            SizedBox(height: 16),
            Text('Client: ${widget.order.customerName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _finalizeDelivery(false);
            },
            child: Text('Client absent'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _finalizeDelivery(false);
            },
            child: Text('Adresse incorrecte'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _finalizeDelivery(false);
            },
            child: Text('Autre problème'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String status) async {
    try {
      // Mettre à jour le statut dans Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.order.id)
          .update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Statut commande mis à jour: $status');
    } catch (e) {
      print('❌ Erreur mise à jour statut: $e');
    }
  }

  Future<void> _finalizeDelivery(bool success) async {
    try {
      final status = success ? 'livre' : 'nonLivre';

      // Mettre à jour le statut de la commande
      await _updateOrderStatus(status);

      // Mettre à jour la position du livreur après livraison
      await DeliveryLocationService.forceUpdateDriverPosition(widget.order.id);

      // Afficher une notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Livraison terminée avec succès!'
              : 'Livraison échouée enregistrée'),
          backgroundColor: success ? Colors.green : Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Retourner à la page précédente
      Navigator.pop(context);
    } catch (e) {
      print('❌ Erreur finalisation livraison: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la finalisation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation - ${widget.order.customerName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Latitude: ${_destination!.latitude}'),
                              Text('Longitude: ${_destination!.longitude}'),
                              SizedBox(height: 8),
                              Text('Client: ${widget.order.customerName}'),
                              Text('Adresse: ${widget.order.customerAddress}'),
                              SizedBox(height: 8),
                              Text('Marqueurs: ${_markers.length}'),
                              Text(
                                  'Marqueurs IDs: ${_markers.map((m) => m.markerId.value).toList()}'),
                              SizedBox(height: 8),
                              Text('Arrivée détectée: $_hasArrived'),
                              Text('Distance: ${_getDistanceToDestination()}m'),
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
                  IconButton(
                    onPressed: () {
                      _hasArrived = true;
                      _showArrivalDialog();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Arrivée forcée'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    },
                    icon: Icon(Icons.location_on),
                    tooltip: 'Forcer arrivée',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? LatLng(6.8270, -5.2890),
              zoom: 15.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onCameraMove: (position) {
              // Optionnel: mettre à jour la position de la caméra
            },
          ),

          // Notification d'arrivée
          if (_hasArrived)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Arrivée à destination!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Client: ${widget.order.customerName}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showArrivalDialog();
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // Boutons d'action
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Bouton "Démarrer la course"
                if (!_isNavigating)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startNavigation,
                      icon: Icon(Icons.directions_car),
                      label: Text('Démarrer la course'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 12),

                // Bouton "Ouvrir Navigation"
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openGoogleMapsNavigation,
                    icon: Icon(Icons.navigation),
                    label: Text('Ouvrir Navigation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
