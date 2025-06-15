import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:liya/modules/restaurant/features/like/application/like_provider.dart';
import 'package:liya/modules/restaurant/features/like/domain/entities/liked_dish.dart';
import 'package:liya/modules/restaurant/features/like/presentation/widgets/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../card/data/datasources/cart_remote_data_source.dart';
import '../../../card/data/models/cart_item_model.dart';
import '../../../card/domain/entities/cart_item.dart';
import '../../../card/domain/repositories/cart_repository.dart';
import '../../../card/domain/usecases/add_to_cart.dart';

@RoutePage(name: 'DishDetailRoute')
class DishDetailPage extends ConsumerStatefulWidget {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final String rating;
  final bool sodas;

  const DishDetailPage({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.description,
    required this.sodas,
  });

  @override
  ConsumerState<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends ConsumerState<DishDetailPage> {
  int quantity = 0;
  bool isLoading = true;
  Map<String, int> sodaQuantities = {};

  @override
  void initState() {
    super.initState();
    loadCurrentQuantity();
  }

  Future<void> loadCurrentQuantity() async {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;

    final phoneNumber = (userDetails['phoneNumber'] ?? '').toString();
    final userId = phoneNumber;
    final cartRepository =
        CartRepositoryImpl(remoteDataSource: CartRemoteDataSourceImpl());

    print('DEBUG: Chargement de la quantité pour ${widget.name}');
    final result = await cartRepository.getCartItems(userId);

    result.fold(
      (failure) {
        print(
            'DEBUG: Erreur lors du chargement de la quantité: ${failure.message}');
        setState(() {
          quantity = 0;
          isLoading = false;
        });
      },
      (cartItems) {
        try {
          final item = cartItems.firstWhere(
            (item) => item.name == widget.name,
            orElse: () => CartItemModel(
              id: '',
              name: '',
              price: '',
              imageUrl: '',
              restaurantId: '',
              description: '',
              rating: '',
              quantity: 0,
              user: '',
              sodas: true,
            ),
          );
          print('DEBUG: Quantité trouvée dans Firestore: ${item.quantity}');
          setState(() {
            quantity = item.quantity;
            isLoading = false;
          });
        } catch (e) {
          print('DEBUG: Erreur lors de la recherche: $e');
          setState(() {
            quantity = 0;
            isLoading = false;
          });
        }
      },
    );
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double basePrice =
        double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double totalPrice = basePrice * quantity;

    return Consumer(
      builder: (context, ref, child) {
        final addToCart = ref.watch(addToCartProvider);

        return Scaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image avec superposition des éléments
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                            child: Image.network(
                              widget.imageUrl,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.5,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.error, size: 300),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 16,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Positioned(
                            top: 60,
                            right: 16,
                            child: Consumer(
                              builder: (context, ref, child) {
                                final userDetailsJson =
                                    singleton<LocalStorageFactory>()
                                        .getUserDetails();
                                final userDetails = userDetailsJson is String
                                    ? jsonDecode(userDetailsJson)
                                    : userDetailsJson;
                                final phoneNumber =
                                    (userDetails['phoneNumber'] ?? '')
                                        .toString();

                                return LikeButton(
                                  dishId: widget.id,
                                  userId: phoneNumber,
                                  name: widget.name,
                                  price: widget.price,
                                  imageUrl: widget.imageUrl,
                                  description: widget.description,
                                  sodas: widget.sodas,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        padding: EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${widget.price} CFA',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                 /* Icon(Icons.star,
                                      size: 20, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    widget.rating,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),*/
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                widget.description,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                              // SECTION BOISSONS AUTOMATIQUE
                              if (widget.sodas == true) ...[
                                const SizedBox(height: 24),
                                const Text(
                                  'Souhaitez vous une boisson ?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final sodasAsync = ref.watch(sodasProvider);
                                    return sodasAsync.when(
                                      loading: () => const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      error: (e, _) => const Text(
                                          'Erreur de chargement des boissons'),
                                      data: (sodas) => Column(
                                        children: sodas.map((soda) {
                                          final firstSize =
                                              soda.sizes.entries.first;
                                          final qty =
                                              sodaQuantities[soda.name] ?? 0;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Row(
                                              children: [
                                                // Nom du soda
                                                Expanded(
                                                  child: Text(
                                                    soda.name,
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                // Prix
                                                Text(
                                                  '+${firstSize.value}',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Contrôles de quantité
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.remove,
                                                            size: 16),
                                                        splashRadius: 18,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                        onPressed: qty > 0
                                                            ? () {
                                                                setState(() {
                                                                  sodaQuantities[
                                                                          soda.name] =
                                                                      qty - 1;
                                                                });
                                                              }
                                                            : null,
                                                      ),
                                                      Container(
                                                        width: 24,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          qty
                                                              .toString()
                                                              .padLeft(2, '0'),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.add,
                                                            size: 16),
                                                        splashRadius: 18,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                        onPressed: () {
                                                          setState(() {
                                                            sodaQuantities[
                                                                    soda.name] =
                                                                qty + 1;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: decrementQuantity,
                                      ),
                                      Text(
                                        '$quantity',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: incrementQuantity,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                /*Expanded(
                                  child: Text(
                                    '${totalPrice.toStringAsFixed(0)} CFA',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),*/
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: quantity > 0
                                ? () async {
                                    final userDetailsJson =
                                        singleton<LocalStorageFactory>()
                                            .getUserDetails();
                                    final userDetails =
                                        userDetailsJson is String
                                            ? jsonDecode(userDetailsJson)
                                            : userDetailsJson;
                                    final phoneNumber =
                                        (userDetails['phoneNumber'] ?? '')
                                            .toString();

                                    final result = await addToCart(
                                      phoneNumber,
                                      CartItemModel(
                                        id: widget.id,
                                        name: widget.name,
                                        price: widget.price,
                                        imageUrl: widget.imageUrl,
                                        restaurantId: widget.restaurantId,
                                        description: widget.description,
                                        rating: widget.rating,
                                        quantity: quantity,
                                        user: phoneNumber,
                                        sodas: widget.sodas,
                                      ),
                                    );

                                    result.fold(
                                      (failure) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Erreur : ${failure?.message ?? 'Inconnue'}"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Plat ajouté au panier avec succès'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              quantity > 0
                                  ? "Panier : $quantity pour ${totalPrice} CFA"
                                  : "Ajouter au panier",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// Modèle pour un soda
class SodaSupplement {
  final String name;
  final bool active;
  final Map<String, String> sizes;

  SodaSupplement({
    required this.name,
    required this.active,
    required this.sizes,
  });

  factory SodaSupplement.fromJson(Map<String, dynamic> json) {
    return SodaSupplement(
      name: json['name'] ?? '',
      active: json['active'] ?? false,
      sizes: Map<String, String>.from(json['sizes'] ?? {}),
    );
  }
}

// Provider pour récupérer les sodas actifs
final sodasProvider = FutureProvider<List<SodaSupplement>>((ref) async {
  final doc = await FirebaseFirestore.instance
      .collection('supplements')
      .doc('global_sodas')
      .get();

  final sodasList = (doc.data()?['sodas'] as List<dynamic>? ?? []);
  return sodasList
      .map((e) => SodaSupplement.fromJson(Map<String, dynamic>.from(e)))
      .where((soda) => soda.active)
      .toList();
});
