import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/routes/app_router.gr.dart';
import '../../domain/entities/delivery_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import '../../../order/domain/entities/order.dart';
import '../../../order/data/models/order_model.dart';
import '../../../order/data/datasources/order_remote_data_source.dart';
import '../../../order/data/repositories/order_repository_impl.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/distance_service.dart';
import 'dart:convert';
import 'package:liya/core/singletons.dart';
import '../../../order/presentation/pages/order_list_page.dart';
import '../../../home/presentation/pages/home_restaurant.dart';
import '../../../../../home/domain/entities/home_option.dart';
import 'package:liya/modules/restaurant/features/card/data/datasources/cart_remote_data_source.dart';
import 'package:liya/modules/restaurant/features/card/data/repositories/cart_repository_impl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/modern_order_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liya/modules/restaurant/features/checkout/presentation/pages/delivery_address_page.dart';

@RoutePage()
class CheckoutPage extends ConsumerStatefulWidget {
  final String restaurantName;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({
    Key? key,
    required this.restaurantName,
    required this.cartItems,
  }) : super(key: key);

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String? phoneInput;
  String? phone;
  String? deliveryInstructions;
  double? selectedLat;
  double? selectedLng;
  String? selectedAddress;
  double? calculatedDistance;
  int? deliveryTime;
  int? deliveryFee;
  final phoneController = TextEditingController();
  final additionalPhoneController = TextEditingController();
  final instructionsController = TextEditingController();
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
  }

  void _initializeUserLocation() {
    final localStorage = singleton<LocalStorageFactory>();

    // Nettoyer les anciennes données si elles correspondent à Abidjan
    if (localStorage.hasUserLocation()) {
      final userLocation = localStorage.getUserLocation();
      if (userLocation.isNotEmpty) {
        final userLat = userLocation['latitude'] as double?;
        final userLng = userLocation['longitude'] as double?;

        // Vérifier si les coordonnées correspondent à Abidjan (5.3xxx, -4.0xxx)
        if (userLat != null && userLng != null) {
          if (userLat < 6.0 || userLng > -4.5) {
            // Coordonnées d'Abidjan détectées, utiliser Yamoussoukro
            _setYamoussoukroAsDefault(localStorage);
            return;
          }

          setState(() {
            selectedLat = userLat;
            selectedLng = userLng;
          });
          _calculateDistance(userLat, userLng);
          _updateAddressFromLatLng(userLat, userLng);
        }
      }
    } else {
      _setYamoussoukroAsDefault(localStorage);
    }
  }

  void _setYamoussoukroAsDefault(LocalStorageFactory localStorage) {
    // Position par défaut : Yamoussoukro
    const defaultLat = 6.8270;
    const defaultLng = -5.2890;

    setState(() {
      selectedLat = defaultLat;
      selectedLng = defaultLng;
    });

    // Sauvegarder la position par défaut
    localStorage.setUserLocation(
      latitude: defaultLat,
      longitude: defaultLng,
      address: 'Yamoussoukro, Région des Lacs, Côte d\'Ivoire',
    );

    _calculateDistance(defaultLat, defaultLng);
    _updateAddressFromLatLng(defaultLat, defaultLng);
  }

  // Méthode pour forcer la réinitialisation des coordonnées
  void _resetToYamoussoukro() {
    final localStorage = singleton<LocalStorageFactory>();

    // Supprimer les anciennes données de localisation
    localStorage.setUserLocation(
      latitude: 6.8270,
      longitude: -5.2890,
      address: 'Yamoussoukro, Région des Lacs, Côte d\'Ivoire',
    );

    // Réinitialiser l'état
    setState(() {
      selectedLat = 6.8270;
      selectedLng = -5.2890;
      calculatedDistance = null;
      deliveryTime = null;
      deliveryFee = null;
    });

    // Recalculer avec les nouvelles coordonnées
    _calculateDistance(6.8270, -5.2890);
    _updateAddressFromLatLng(6.8270, -5.2890);
  }

  @override
  void dispose() {
    phoneController.dispose();
    additionalPhoneController.dispose();
    instructionsController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _updateAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          selectedAddress =
              '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        });
      }
    } catch (e) {
      // Adresse par défaut pour Yamoussoukro
      setState(() {
        selectedAddress =
            'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
      });
    }

    // Centrer la carte sur la nouvelle position
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }

    // Calculer la distance
    _calculateDistance(lat, lng);

    // Sauvegarder la nouvelle position dans le localStorage
    final localStorage = singleton<LocalStorageFactory>();
    localStorage.setUserLocation(
      latitude: lat,
      longitude: lng,
      address: selectedAddress ?? 'Position actuelle',
    );
  }

  void _calculateDistance(double lat, double lng) {
    final distance = DistanceService.calculateDistanceToRestaurant(lat, lng);
    final time = DistanceService.calculateDeliveryTime(distance);
    final fee = DistanceService.calculateDeliveryFee(distance);

    setState(() {
      calculatedDistance = distance;
      deliveryTime = time;
      deliveryFee = fee;
    });
  }

  // Méthode pour mettre à jour la carte avec les nouvelles coordonnées
  Future<void> _updateMapWithNewLocation(double lat, double lng) async {
    setState(() {
      selectedLat = lat;
      selectedLng = lng;
    });

    // Centrer la carte sur la nouvelle position
    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15.0,
          ),
        ),
      );
    }

    // Recalculer la distance
    _calculateDistance(lat, lng);
  }

  Future<void> _showPhoneDialog() async {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    final controller = TextEditingController(text: phone ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact supplémentaire'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone',
            hintText: 'Ex: +225 0701234567',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                phone = controller.text.isNotEmpty ? controller.text : null;
              });
              Navigator.pop(context, controller.text);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Méthode pour changer l'adresse de livraison
  Future<void> _showAddressChangeDialog() async {
    final controller = TextEditingController(text: selectedAddress ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier l\'adresse de livraison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Nouvelle adresse',
                hintText: 'Ex: 04 BP YAM 04, Yamoussoukro',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ou utilisez votre position actuelle',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _getCurrentLocation();
              },
              icon: Icon(Icons.my_location),
              label: Text('Utiliser ma position'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _updateAddressFromText(controller.text);
              }
              Navigator.pop(context, controller.text);
            },
            child: Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    try {
      // Demander les permissions de localisation
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permission de localisation refusée')),
          );
          return;
        }
      }

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UIColors.orange),
          ),
        ),
      );

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Fermer le dialogue de chargement
      Navigator.pop(context);

      // Mettre à jour l'adresse avec la nouvelle position
      await _updateAddressFromLatLng(position.latitude, position.longitude);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Position actuelle utilisée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'obtention de la position: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mettre à jour l'adresse à partir du texte
  Future<void> _updateAddressFromText(String address) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UIColors.orange),
          ),
        ),
      );

      // Convertir l'adresse en coordonnées
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;

        setState(() {
          selectedLat = location.latitude;
          selectedLng = location.longitude;
          selectedAddress = address;
        });

        // Recalculer la distance et les frais
        _calculateDistance(location.latitude, location.longitude);

        // Centrer la carte
        if (mapController != null) {
          await mapController!.animateCamera(
            CameraUpdate.newLatLng(
                LatLng(location.latitude, location.longitude)),
          );
        }

        // Sauvegarder la nouvelle position
        final localStorage = singleton<LocalStorageFactory>();
        localStorage.setUserLocation(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
        );
      }

      // Fermer le dialogue de chargement
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adresse mise à jour'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour de l\'adresse: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showInstructionsDialog() async {
    final controller = TextEditingController(text: deliveryInstructions ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Instructions de livraison'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Ex: Laisser devant la porte'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('Valider')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => deliveryInstructions = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    final userLocation = singleton<LocalStorageFactory>().getUserLocation();
    final userLat = userLocation['latitude'] as double?;
    final userLng = userLocation['longitude'] as double?;
    final userAddress = userLocation['address'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              'Paiement',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Bouton de debug temporaire
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange),
            onPressed: () => _resetToYamoussoukro(),
            tooltip: 'Réinitialiser à Yamoussoukro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Section
            Container(
              height: 200,
              child: Stack(
                children: [
                  // Carte grisée (non interactive)
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          LatLng(selectedLat ?? 6.8270, selectedLng ?? -5.2890),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    // Désactiver les interactions
                    onTap: null,
                    onLongPress: null,
                    onCameraMove: null,
                    markers: selectedLat != null && selectedLng != null
                        ? {
                            Marker(
                              markerId: MarkerId('delivery_location'),
                              position: LatLng(selectedLat!, selectedLng!),
                              infoWindow: InfoWindow(
                                title: 'Adresse de livraison',
                                snippet:
                                    selectedAddress ?? 'Adresse sélectionnée',
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueOrange),
                              // Rendre le marqueur plus visible
                              draggable: false,
                              flat: false,
                              anchor: Offset(0.5, 1.0),
                            ),
                          }
                        : {},
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    // Désactiver les contrôles de carte
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                  ),

                  // Overlay grisé pour indiquer que la carte n'est pas interactive
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),

                  // Bouton pour modifier l'adresse
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DeliveryAddressPage(
                                initialLocation:
                                    selectedLat != null && selectedLng != null
                                        ? LatLng(selectedLat!, selectedLng!)
                                        : null,
                                initialAddress: selectedAddress,
                              ),
                            ),
                          );

                          if (result != null) {
                            // Utiliser la nouvelle méthode pour mettre à jour la carte
                            await _updateMapWithNewLocation(
                              result['latitude'],
                              result['longitude'],
                            );

                            // Mettre à jour l'adresse
                            setState(() {
                              selectedAddress = result['address'];
                            });
                          }
                        },
                        icon: Icon(Icons.edit_location),
                        tooltip: 'Modifier l\'adresse',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                  // Indicateur "Carte non interactive"
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Appuyez sur l\'icône pour modifier',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Time Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Temps de livraison',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      Text(
                        calculatedDistance != null
                            ? DistanceService.formatDeliveryTime(deliveryTime!)
                            : 'Calcul...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Frais de livraison
                  if (deliveryFee != null) ...[
                    Row(
                      children: [
                        Icon(Icons.delivery_dining, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Frais de livraison',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Text(
                          DistanceService.formatDeliveryFee(deliveryFee!),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: UIColors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: UIColors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Standard',
                                style: TextStyle(
                                  color: UIColors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                calculatedDistance != null
                                    ? DistanceService.formatDistance(
                                        calculatedDistance!)
                                    : 'Calcul...',
                                style: TextStyle(color: Colors.grey),
                              ),
                              if (deliveryTime != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  DistanceService.formatDeliveryTime(
                                      deliveryTime!),
                                  style: TextStyle(
                                    color: UIColors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
/*                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                             */ /* Text(
                                'Programmer',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Choisir une heure',
                                style: TextStyle(color: Colors.grey),
                              ),*/ /*
                            ],
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),

            // Address Section
            ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text('Adresse de livraison'),
              subtitle: Text(
                selectedAddress ?? 'Sélectionnez une adresse',
                style: TextStyle(
                  color: selectedAddress != null ? Colors.black87 : Colors.grey,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedAddress != null)
                    Icon(Icons.check_circle, color: UIColors.orange, size: 20),
                  SizedBox(width: 8),
                  Icon(Icons.edit_location, color: UIColors.orange),
                ],
              ),
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeliveryAddressPage(
                      initialLocation:
                          selectedLat != null && selectedLng != null
                              ? LatLng(selectedLat!, selectedLng!)
                              : null,
                      initialAddress: selectedAddress,
                    ),
                  ),
                );

                if (result != null) {
                  // Utiliser la nouvelle méthode pour mettre à jour la carte
                  await _updateMapWithNewLocation(
                    result['latitude'],
                    result['longitude'],
                  );

                  // Mettre à jour l'adresse
                  setState(() {
                    selectedAddress = result['address'];
                  });
                }
              },
            ),

            // Delivery Instructions
            /* ListTile(
              leading: Icon(Icons.gps_fixed),
              title: Text('Coordonnées'),
              subtitle: Text(selectedLat != null && selectedLng != null
                  ? '${selectedLat!.toStringAsFixed(5)}, ${selectedLng!.toStringAsFixed(5)}'
                  : 'Non sélectionnées'),
            ),*/

            // Phone Number (invariable)
            ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('Numéro de téléphone'),
              subtitle: Text(phoneNumber),
              trailing: Icon(Icons.lock, size: 16, color: Colors.grey),
            ),

            // Contact supplémentaire (modifiable)
            ListTile(
              leading: Icon(Icons.contact_phone_outlined),
              title: Text('Contact supplémentaire'),
              subtitle: Text(
                phone ?? 'Utilisera le numéro principal',
                style: TextStyle(
                  color: phone != null ? Colors.black87 : Colors.grey,
                ),
              ),
              trailing: Icon(Icons.edit),
              onTap: _showPhoneDialog,
            ),

            // Send as Gift
            /* ListTile(
              leading: Icon(Icons.card_giftcard_outlined),
              title: Text('Envoyer comme cadeau'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to gift options
              },
            ),*/

            // Cart Summary
            ExpansionTile(
              leading: Icon(Icons.shopping_cart_outlined),
              title: Text('Résumé de la commande'),
              subtitle: Text(
                  '${widget.restaurantName} • ${widget.cartItems.length} articles'),
              children: [
                ...widget.cartItems.map((item) => ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['imageUrl'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                      title: Text(item['name']),
                      subtitle: Text('Quantité: ${item['quantity']}'),
                      trailing: Text('${item['price']} CFA'),
                    )),
              ],
            ),

            // Calcul détaillé
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calcul détaillé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sous-total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sous-total'),
                      Text(
                        '${_calculateSubtotal()} FCFA',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Frais de livraison
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Frais de livraison'),
                      Text(
                        deliveryFee != null
                            ? '${deliveryFee} FCFA'
                            : 'Calcul...',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: UIColors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ligne de séparation
                  const Divider(),
                  const SizedBox(height: 8),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_calculateTotal()} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: UIColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Instructions
            ListTile(
              leading: Icon(Icons.shopping_bag_outlined),
              title: Text('Instructions de livraison'),
              subtitle: Text(deliveryInstructions ?? 'Aucune'),
              trailing: Icon(Icons.edit),
              onTap: _showInstructionsDialog,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
              // Vérifier qu'une adresse est sélectionnée
              if (selectedLat == null ||
                  selectedLng == null ||
                  selectedAddress == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Veuillez sélectionner une adresse de livraison sur la carte'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Vérifier que la distance est calculée
              if (calculatedDistance == null || deliveryFee == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Erreur lors du calcul de la distance. Veuillez réessayer.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Crée la liste des OrderItem
              final items = widget.cartItems
                  .map((item) => OrderItemModel(
                        name: item['name'],
                        quantity: item['quantity'],
                        price: double.tryParse(item['price'].toString()) ?? 0.0,
                      ))
                  .toList();

              // Calcule les totaux
              final subtotal = _calculateSubtotal();
              final total = _calculateTotal();

              // Crée l'objet Order avec les informations de livraison
              final order = OrderModel(
                id: '', // Laisse vide, le repo s'en charge
                phoneNumber: phoneNumber, // Numéro principal (invariable)
                phone: phone ??
                    phoneNumber, // Contact supplémentaire ou phoneNumber par défaut
                items: items,
                total: total, // Total incluant les frais de livraison
                subtotal: subtotal,
                deliveryFee: deliveryFee!,
                status: OrderStatus.reception,
                createdAt: DateTime.now(),
                latitude: selectedLat,
                longitude: selectedLng,
                deliveryInstructions: deliveryInstructions,
                distance: calculatedDistance,
                deliveryTime: deliveryTime,
                address: selectedAddress,
              );

              // Debug: Afficher les données de la commande
              print('DEBUG - Order data:');
              print('phoneNumber: ${order.phoneNumber}');
              print('phone: ${order.phone}');
              print('phone variable: $phone');
              print('toJson: ${order.toJson()}');
              print('phone in toJson: ${order.toJson()['phone']}');

              // Enregistre la commande sur Firestore avec les détails de livraison
              final dataSource = OrderRemoteDataSourceImpl(
                  firestore: cf.FirebaseFirestore.instance);
              final repository = OrderRepositoryImpl(dataSource);

              try {
                await repository.createOrder(order);

                // Vide le panier Firestore
                final cartRepo = CartRepositoryImpl(
                    remoteDataSource: CartRemoteDataSourceImpl());
                await cartRepo.clearCart(phoneNumber);

                // Vider la commande moderne (modernOrderProvider)
                ref.read(modernOrderProvider.notifier).clearOrder();

                if (!context.mounted) return;

                // Afficher le message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Commande enregistrée ! Total: ${total.toStringAsFixed(0)} FCFA'),
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Attendre que le SnackBar soit visible
                await Future.delayed(const Duration(milliseconds: 500));
                if (!context.mounted) return;

                // Rediriger vers la page d'accueil du restaurant
                try {
                  context.router
                      .replace(OrderListRoute(phoneNumber: phoneNumber));
                } catch (e) {
                  // En cas d'erreur, essayer une navigation plus simple
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomeRestaurantPage(
                          option: const HomeOption(
                            title: 'Restaurants',
                            icon: 'restaurant',
                          ),
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'enregistrement: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Confirmer la commande • ${_calculateTotal().toStringAsFixed(0)} FCFA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calculateSubtotal() {
    return widget.cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final quantity = item['quantity'] as int? ?? 1;
      final accompaniments = item['accompaniments'] as List<dynamic>? ?? [];

      // Prix du plat
      final itemPrice = price * quantity;

      // Prix des accompagnements
      final accompanimentsPrice = accompaniments.fold(0.0, (accSum, acc) {
        final accPrice = (acc['price'] as num?)?.toDouble() ?? 0.0;
        return accSum + accPrice;
      });

      return sum + itemPrice + accompanimentsPrice;
    });
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final deliveryFeeAmount = deliveryFee?.toDouble() ?? 0.0;
    return subtotal + deliveryFeeAmount;
  }
}
