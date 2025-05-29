import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../card/data/datasources/cart_remote_data_source.dart';
import '../../../card/data/models/cart_item_model.dart';
import '../../../card/domain/entities/cart_item.dart';
import '../../../card/domain/repositories/cart_repository.dart';

@RoutePage(name: 'DishDetailRoute')
class DishDetailPage extends ConsumerStatefulWidget {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final String rating;

  const DishDetailPage({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });

  @override
  ConsumerState<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends ConsumerState<DishDetailPage> {
  int quantity = 0;
  bool isLoading = true;

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

    final phoneNumber = userDetails['phoneNumber'] ?? '';
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

  void decrementQuantity() async {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });

      // Si la quantité atteint 0, supprimer l'article du panier
      if (quantity == 0) {
        await removeFromCart();
      } else {
        // Sinon, mettre à jour la quantité dans Firestore
        await updateCartQuantity();
      }
    }
  }

  Future<void> removeFromCart() async {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;

    final phoneNumber = userDetails['phoneNumber'] ?? '';
    final userId = phoneNumber;
    final cartRepository =
        CartRepositoryImpl(remoteDataSource: CartRemoteDataSourceImpl());

    print('DEBUG: Suppression du plat ${widget.name} du panier');
    // Implémenter la suppression dans CartRemoteDataSource
    try {
      await cartRepository.removeFromCart(userId, widget.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.name} retiré du panier')),
      );
    } catch (e) {
      print('DEBUG: Erreur lors de la suppression: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du plat')),
      );
    }
  }

  Future<void> updateCartQuantity() async {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    final userId = phoneNumber;
    final cartItem = CartItem(
      id: widget.name,
      name: widget.name,
      price: widget.price,
      imageUrl: widget.imageUrl,
      restaurantId: widget.restaurantId,
      description: widget.description,
      rating: widget.rating,
      quantity: quantity,
      user: userId,
    );

    final addToCart = ref.read(addToCartProvider);
    final result = await addToCart(userId, cartItem);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la mise à jour: ${failure.message}')),
      ),
      (_) => print('DEBUG: Quantité mise à jour: $quantity'),
    );
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
                            child: Icon(Icons.favorite_border,
                                color: Colors.orange, size: 24),
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
                                  Icon(Icons.star,
                                      size: 20, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    widget.rating,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                widget.description,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
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
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove,
                                          color: Colors.black),
                                      onPressed: decrementQuantity,
                                    ),
                                    Text(
                                      quantity.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.black),
                                      onPressed: incrementQuantity,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                if (quantity > 0) {
                                  await updateCartQuantity();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                quantity > 0
                                    ? "panier : $quantity pour ${totalPrice.toStringAsFixed(3)} CFA"
                                    : "Ajouter au panier",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
        );
      },
    );
  }
}
