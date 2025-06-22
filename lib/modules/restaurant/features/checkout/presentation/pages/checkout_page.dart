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
import 'dart:convert';
import 'package:liya/core/singletons.dart';
import '../../../order/presentation/pages/order_list_page.dart';
import '../../../home/presentation/pages/home_restaurant.dart';
import '../../../../../home/domain/entities/home_option.dart';
import 'package:liya/modules/restaurant/features/card/data/datasources/cart_remote_data_source.dart';
import 'package:liya/modules/restaurant/features/card/data/repositories/cart_repository_impl.dart';
import 'package:geocoding/geocoding.dart';

@RoutePage()
class CheckoutPage extends StatefulWidget {
  final String restaurantName;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({
    Key? key,
    required this.restaurantName,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? phoneInput;
  String? deliveryInstructions;
  double? selectedLat;
  double? selectedLng;
  String? selectedAddress;
  final phoneController = TextEditingController();
  final instructionsController = TextEditingController();

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
                        '16-21 min',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
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
                                '16-21 min',
                                style: TextStyle(color: Colors.grey),
                              ),
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
                             *//* Text(
                                'Programmer',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Choisir une heure',
                                style: TextStyle(color: Colors.grey),
                              ),*//*
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
              subtitle: Text(selectedAddress ?? 'Sélectionnez sur la carte'),
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
              // Crée la liste des OrderItem
              final items = widget.cartItems
                  .map((item) => OrderItem(
                        name: item['name'],
                        quantity: item['quantity'],
                        price: double.tryParse(item['price'].toString()) ?? 0.0,
                      ))
                  .toList();

              // Calcule le total
              final total = items.fold(
                  0.0, (sum, item) => sum + item.price * item.quantity);

              // Crée l'objet Order (l'id sera généré par le repo)
              final order = Order(
                id: '', // Laisse vide, le repo s'en charge
                phoneNumber: phoneInput ?? phoneNumber,
                items: items,
                total: total,
                status: OrderStatus.reception,
                createdAt: DateTime.now(),
                latitude: selectedLat,
                longitude: selectedLng,
                deliveryInstructions: deliveryInstructions,
              );

              // Enregistre la commande sur Firestore
              final dataSource = OrderRemoteDataSourceImpl(
                  firestore: cf.FirebaseFirestore.instance);
              final repository = OrderRepositoryImpl(dataSource);
              await repository.createOrder(order);

              // Vide le panier Firestore
              final cartRepo = CartRepositoryImpl(
                  remoteDataSource: CartRemoteDataSourceImpl());
              await cartRepo.clearCart(phoneNumber);

              if (!context.mounted) return;

              // Afficher le message de confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Commande enregistrée !'),
                  duration: Duration(seconds: 2),
                ),
              );

              // Attendre que le SnackBar soit visible
              await Future.delayed(const Duration(milliseconds: 500));
              if (!context.mounted) return;

              // Rediriger vers la page d'accueil du restaurant
              try {
                /*Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => HomeRestaurantPage(
                      option: const HomeOption(
                        title: 'Restaurants',
                        icon: 'restaurant',
                      ),
                    ),
                  ),
                  (route) => false,
                );*/
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Confirmer la commande',
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
}
