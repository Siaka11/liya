import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import '../../../../../../routes/app_router.gr.dart';
import '../../domain/entities/delivery_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import '../../../order/domain/entities/order.dart';
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
  String? deliveryInstructions;
  double? selectedLat;
  double? selectedLng;
  String? selectedAddress;
  double? calculatedDistance;
  int? deliveryTime;
  int? deliveryFee;
  final phoneController = TextEditingController();
  final instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
  }

  void _initializeUserLocation() {
    final localStorage = singleton<LocalStorageFactory>();
    if (localStorage.hasUserLocation()) {
      final userLocation = localStorage.getUserLocation();
      if (userLocation.isNotEmpty) {
        final userLat = userLocation['latitude'] as double?;
        final userLng = userLocation['longitude'] as double?;

        if (userLat != null && userLng != null) {
          _calculateDistance(userLat, userLng);
        }
      }
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    instructionsController.dispose();
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
      setState(() {
        selectedAddress =
            'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
      });
    }

    // Calculer la distance
    _calculateDistance(lat, lng);
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

  Future<void> _showPhoneDialog() async {
    final controller = TextEditingController(text: phoneInput ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Numéro de téléphone'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(hintText: 'Entrez votre numéro'),
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
      setState(() => phoneInput = result);
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
            Text(
              widget.restaurantName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Section
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(6.8276, -5.2893), // Coordonnées de Yamoussoukro
                  zoom: 15,
                ),
                onTap: (LatLng pos) async {
                  setState(() {
                    selectedLat = pos.latitude;
                    selectedLng = pos.longitude;
                  });
                  await _updateAddressFromLatLng(pos.latitude, pos.longitude);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
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
              subtitle: Text(userAddress ?? 'Sélectionnez sur la carte'),
            ),

            // Delivery Instructions
            /* ListTile(
              leading: Icon(Icons.gps_fixed),
              title: Text('Coordonnées'),
              subtitle: Text(selectedLat != null && selectedLng != null
                  ? '${selectedLat!.toStringAsFixed(5)}, ${selectedLng!.toStringAsFixed(5)}'
                  : 'Non sélectionnées'),
            ),*/

            // Phone Number
            ListTile(
              leading: Icon(Icons.phone_outlined),
              title: Text('Numéro de téléphone'),
              subtitle: Text(phoneInput ?? phoneNumber),
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
              // Vérifier que la distance est calculée
              if (calculatedDistance == null || deliveryFee == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Veuillez sélectionner une adresse de livraison'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Crée la liste des OrderItem
              final items = widget.cartItems
                  .map((item) => OrderItem(
                        name: item['name'],
                        quantity: item['quantity'],
                        price: double.tryParse(item['price'].toString()) ?? 0.0,
                      ))
                  .toList();

              // Calcule les totaux
              final subtotal = _calculateSubtotal();
              final total = _calculateTotal();

              // Crée l'objet Order avec les informations de livraison
              final order = Order(
                id: '', // Laisse vide, le repo s'en charge
                phoneNumber: phoneInput ?? phoneNumber,
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
      return sum + (price * quantity);
    });
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final deliveryFeeAmount = deliveryFee?.toDouble() ?? 0.0;
    return subtotal + deliveryFeeAmount;
  }
}
