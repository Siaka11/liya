import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/ui/theme/theme.dart';
import '../../application/delivery_location_provider.dart';
import '../../domain/entities/delivery_order.dart';

@RoutePage()
class DeliveryOrdersPage extends ConsumerStatefulWidget {
  const DeliveryOrdersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DeliveryOrdersPage> createState() => _DeliveryOrdersPageState();
}

class _DeliveryOrdersPageState extends ConsumerState<DeliveryOrdersPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _updateMapMarkers();
    } catch (e) {
      print('Erreur obtention position: $e');
    }
  }

  void _updateMapMarkers() {
    _markers.clear();

    if (_currentPosition != null) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(deliveryLocationProvider);
    final locationNotifier = ref.read(deliveryLocationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statut en ligne
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: locationState.isOnline
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              border: Border(
                bottom: BorderSide(
                  color: locationState.isOnline ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: locationState.isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locationState.isOnline ? 'En ligne' : 'Hors ligne',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: locationState.isOnline
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      Text(
                        locationState.isSharingLocation
                            ? 'Partage de position actif'
                            : 'Partage de position inactif',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!locationState.isSharingLocation)
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implémenter la méthode startLocationSharing
                      print('Activer le partage de localisation');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Activer'),
                  ),
              ],
            ),
          ),

          // Carte avec position actuelle et destination
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(6.8270, -5.2890),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
          ),

          // Liste des commandes assignées
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commandes Assignées',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (locationState.currentDeliveryUser?.currentOrderId != null)
                  _buildAssignedOrderCard(
                    locationState.currentDeliveryUser!.currentOrderId!,
                    locationNotifier,
                  )
                else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Aucune commande assignée',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
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

  Widget _buildAssignedOrderCard(
      String orderId, DeliveryLocationNotifier locationNotifier) {
    return FutureBuilder<Map<String, double>?>(
      future: locationNotifier.getOrderDestinationCoordinates(orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final destinationCoords = snapshot.data;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.delivery_dining, color: UIColors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Commande #$orderId',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'En cours',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (destinationCoords != null) ...[
                  Text(
                    'Destination:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${destinationCoords['latitude']!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Lng: ${destinationCoords['longitude']!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPosition != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showRouteToDestination(destinationCoords);
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('Voir l\'itinéraire'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UIColors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implémenter la méthode updateLocationWithDestination
                              print(
                                  'Mettre à jour la localisation avec destination: $orderId');
                            },
                            icon: const Icon(Icons.update),
                            label: const Text('Mettre à jour'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  const Text(
                    'Coordonnées de destination non disponibles',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRouteToDestination(Map<String, double> destinationCoords) {
    if (_currentPosition == null) return;

    setState(() {
      _markers.clear();
      _polylines.clear();

      // Marqueur de position actuelle
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

      // Marqueur de destination
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
              destinationCoords['latitude']!, destinationCoords['longitude']!),
          infoWindow: const InfoWindow(
            title: 'Destination',
            snippet: 'Point de livraison',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Itinéraire
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            LatLng(destinationCoords['latitude']!,
                destinationCoords['longitude']!),
          ],
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dot, PatternItem.gap(10)],
        ),
      );
    });

    // Centrer la carte sur l'itinéraire
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentPosition!.latitude < destinationCoords['latitude']!
                ? _currentPosition!.latitude
                : destinationCoords['latitude']!,
            _currentPosition!.longitude < destinationCoords['longitude']!
                ? _currentPosition!.longitude
                : destinationCoords['longitude']!,
          ),
          northeast: LatLng(
            _currentPosition!.latitude > destinationCoords['latitude']!
                ? _currentPosition!.latitude
                : destinationCoords['latitude']!,
            _currentPosition!.longitude > destinationCoords['longitude']!
                ? _currentPosition!.longitude
                : destinationCoords['longitude']!,
          ),
        ),
        50,
      ),
    );
  }
}
