import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/delivery_order.dart';
import '../../application/home_delivery_provider.dart';
import 'delivery_navigation_page.dart';

class OrderDetailsPage extends ConsumerStatefulWidget {
  final DeliveryOrder order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  ConsumerState<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends ConsumerState<OrderDetailsPage> {
  bool _showMap = false;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoadingMap = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF24E1E),
        elevation: 0,
        title: Text(
          'Commande ${widget.order.id}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showMap ? Icons.list : Icons.map,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec statut
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF24E1E),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.order.type == DeliveryType.restaurant
                              ? Icons.restaurant
                              : Icons.local_shipping,
                          color: const Color(0xFFF24E1E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.order.type == DeliveryType.restaurant
                              ? 'Restaurant'
                              : 'Colis',
                          style: const TextStyle(
                            color: Color(0xFFF24E1E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  /*Text(
                    '${widget.order.deliveryFee.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Gain de livraison',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),*/
                ],
              ),
            ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Informations client
                  _buildInfoCard(
                    title: 'Informations Client',
                    icon: Icons.person,
                    children: [
                      _buildInfoRow('Nom', widget.order.customerName),
                      _buildInfoRow(
                          'Téléphone', widget.order.customerPhoneNumber),
                      _buildInfoRow('Adresse', widget.order.customerAddress),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Détails de la commande
                  _buildInfoCard(
                    title: 'Détails de la Commande',
                    icon: Icons.receipt,
                    children: [
                      _buildInfoRow('ID', widget.order.id),
                      _buildInfoRow('Description', widget.order.description),
                      /* _buildInfoRow('Montant',
                          '${widget.order.amount.toStringAsFixed(0)} FCFA'),
                      _buildInfoRow('Frais de livraison',
                          '${widget.order.deliveryFee.toStringAsFixed(0)} FCFA'),
                      _buildInfoRow('Total',
                          '${(widget.order.amount + widget.order.deliveryFee).toStringAsFixed(0)} FCFA'),*/
                      _buildInfoRow(
                          'Statut', _getStatusText(widget.order.status)),
                      if (widget.order.createdAt != null)
                        _buildInfoRow(
                            'Créée le',
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(widget.order.createdAt!)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Carte (placeholder pour l'instant)
                  if (_showMap) ...[
                    _buildInfoCard(
                      title: 'Carte de Navigation',
                      icon: Icons.map,
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _isLoadingMap
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text('Chargement de la carte...'),
                                      ],
                                    ),
                                  )
                                : _currentPosition == null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 48,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Position non disponible',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: _getCurrentLocation,
                                              child: const Text('Réessayer'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : GoogleMap(
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          _mapController = controller;
                                          _createMarkers();
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            _currentPosition!.latitude,
                                            _currentPosition!.longitude,
                                          ),
                                          zoom: 15.0,
                                        ),
                                        markers: _markers,
                                        myLocationEnabled: true,
                                        myLocationButtonEnabled: true,
                                        zoomControlsEnabled: true,
                                        mapToolbarEnabled: false,
                                      ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Votre position'),
                            const Spacer(),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Destination: ${widget.order.customerName}'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DeliveryNavigationPage(
                                  order: widget.order,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Navigation'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConfirmationDialog(
                            'Démarrer la livraison',
                            'Êtes-vous sûr de vouloir démarrer cette livraison ?',
                            () => ref
                                .read(homeDeliveryProvider.notifier)
                                .startDelivery(widget.order),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Démarrer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConfirmationDialog(
                            'Terminer la livraison',
                            'Êtes-vous sûr de vouloir terminer cette livraison ?',
                            () => ref
                                .read(homeDeliveryProvider.notifier)
                                .completeDelivery(widget.order),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Terminer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showConfirmationDialog(
                            'Échouer la livraison',
                            'Êtes-vous sûr de vouloir marquer cette livraison comme échouée ?',
                            () => ref
                                .read(homeDeliveryProvider.notifier)
                                .failDelivery(widget.order),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Échouer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF24E1E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.reception:
        return 'En attente';
      case DeliveryStatus.assigned:
        return 'Assigné à un livreur';
      case DeliveryStatus.enRoute:
        return 'En cours de livraison';
      case DeliveryStatus.livre:
        return 'Livré';
      case DeliveryStatus.nonLivre:
        return 'Non livré';
      default:
        return 'Inconnu';
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Text(
          'Êtes-vous sûr de vouloir marquer cette livraison comme terminée ?\n\n'
          '${widget.order.description}\n'
          'Client: ${widget.order.customerName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(homeDeliveryProvider.notifier)
                  .completeDelivery(widget.order);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Livraison terminée avec succès !'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingMap = true;
      });

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permission de localisation refusée');
          return;
        }
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingMap = false;
      });

      // Créer les marqueurs avec destination
      await _updateMapWithDestination();

      // Animer la carte vers la position actuelle
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur récupération position: $e');
      setState(() {
        _isLoadingMap = false;
      });
    }
  }

  void _createMarkers() async {
    if (_currentPosition == null) return;

    _markers.clear();

    // Marqueur pour la position actuelle
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

    // Marqueur pour la destination
    final destination = await _getDestinationCoordinates();
    if (destination != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          infoWindow: InfoWindow(
            title: widget.order.customerName,
            snippet: widget.order.customerAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {});
  }

  Future<LatLng?> _getDestinationCoordinates() async {
    try {
      // Pour l'instant, on utilise des coordonnées simulées
      // TODO: Récupérer les vraies coordonnées depuis Firestore
      if (_currentPosition == null) return null;

      // Simuler une destination à 1km au nord-est
      final destinationLat = _currentPosition!.latitude + 0.01;
      final destinationLng = _currentPosition!.longitude + 0.01;

      return LatLng(destinationLat, destinationLng);
    } catch (e) {
      print('❌ Erreur récupération coordonnées destination: $e');
      return null;
    }
  }

  Future<void> _updateMapWithDestination() async {
    final destination = await _getDestinationCoordinates();
    if (destination != null) {
      _createMarkers();

      // Animer la carte pour montrer les deux points
      if (_mapController != null && _currentPosition != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            _currentPosition!.latitude < destination.latitude
                ? _currentPosition!.latitude
                : destination.latitude,
            _currentPosition!.longitude < destination.longitude
                ? _currentPosition!.longitude
                : destination.longitude,
          ),
          northeast: LatLng(
            _currentPosition!.latitude > destination.latitude
                ? _currentPosition!.latitude
                : destination.latitude,
            _currentPosition!.longitude > destination.longitude
                ? _currentPosition!.longitude
                : destination.longitude,
          ),
        );

        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0),
        );
      }
    }
  }

  void _showConfirmationDialog(
      String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
