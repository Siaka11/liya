import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TestDeliveryTrackingPage extends ConsumerStatefulWidget {
  const TestDeliveryTrackingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TestDeliveryTrackingPage> createState() =>
      _TestDeliveryTrackingPageState();
}

class _TestDeliveryTrackingPageState
    extends ConsumerState<TestDeliveryTrackingPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  String _status = 'Initialisation...';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _status = 'Demande des permissions...';
    });

    try {
      // Demander les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _status = 'Permission de localisation refusée';
          });
          return;
        }
      }

      setState(() {
        _status = 'Récupération de la position...';
      });

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Ajouter le marqueur de position actuelle
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Votre position',
            snippet: 'Position actuelle',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      // Ajouter un marqueur fictif pour le livreur (pour test)
      _markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: LatLng(
            _currentPosition!.latitude + 0.001, // 100m au nord
            _currentPosition!.longitude + 0.001, // 100m à l'est
          ),
          infoWindow: const InfoWindow(
            title: 'Livreur (test)',
            snippet: 'Position fictive pour test',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      setState(() {
        _status = 'Carte initialisée avec succès';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Suivi Livraison'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeMap,
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte
          Expanded(
            flex: 3,
            child: _currentPosition != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 15,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),

          // Informations
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut: $_status',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentPosition != null) ...[
                    Text(
                      'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Précision: ${_currentPosition!.accuracy.toStringAsFixed(1)} m',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Test de fonctionnalités:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ Carte Google Maps\n'
                    '✅ Localisation GPS\n'
                    '✅ Marqueurs sur la carte\n'
                    '✅ Position actuelle\n'
                    '✅ Marqueur livreur (test)',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Test de centrage sur la position
          if (_currentPosition != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              ),
            );
          }
        },
        icon: const Icon(Icons.my_location),
        label: const Text('Ma position'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
