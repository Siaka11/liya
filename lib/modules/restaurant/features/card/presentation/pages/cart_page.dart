import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/card/data/datasources/cart_remote_data_source.dart';
import 'package:liya/modules/restaurant/features/card/domain/repositories/cart_repository.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/dish_card.dart';
import 'package:liya/routes/app_router.gr.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';

@RoutePage(name: 'CartRoute')
class CartPage extends ConsumerWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartRepository = CartRepositoryImpl(
      remoteDataSource: CartRemoteDataSourceImpl(),
    );

    // StateProvider pour forcer le rafraîchissement
    final refreshKey = StateProvider((ref) => 0);
    final refreshCount = ref.watch(refreshKey);
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      appBar: AppBar(
        title: const Text('Mon panier', style: TextStyle(color: Colors.orange)),
        leading: BackButton(
          color: UIColors.orange,
        ),
      ),
      body: FutureBuilder(
        key: ValueKey(refreshCount),
        future: cartRepository.getCartItems(phoneNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement du panier',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          final cartItemsResult = snapshot.data;
          if (cartItemsResult == null) {
            return Center(child: Text('Panier vide'));
          }

          return cartItemsResult.fold(
            (failure) => Center(child: Text("Erreur lors du chargement")),
            (cartItems) {
              if (cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Votre panier est vide',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              double total = cartItems.fold(
                0,
                (sum, item) =>
                    sum + (double.tryParse(item.price) ?? 0) * item.quantity,
              );

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return DishCard(
                          name: item.name,
                          price: item.price,
                          imageUrl: item.imageUrl,
                          description: item.description ?? '',
                          quantity: item.quantity,
                          onDelete: () async {
                            try {
                              await cartRepository.removeFromCart(
                                  phoneNumber, item.id);
                              // Forcer le rafraîchissement de la page
                              ref.read(refreshKey.notifier).state++;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Article supprimé du panier'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Erreur lors de la suppression: [38;5;9m${e.toString()}[0m'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          onTap: () async {
                            // Navigation vers la page de détails du plat
                            await context.router.push(
                              DishDetailRoute(
                                  id: item.id ?? '',
                                  restaurantId: item.restaurantId ?? '',
                                  name: item.name,
                                  price: item.price,
                                  imageUrl: item.imageUrl,
                                  rating: '0.0',
                                  description: item.description ?? '',
                                  sodas: item.sodas),
                            );
                            // Rafraîchir la page après le retour
                            ref.read(refreshKey.notifier).state++;
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${total.toStringAsFixed(3)} CFA',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: UIColors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: cartItems.isEmpty
                                ? null
                                : () {
                                    context.router.push(
                                      CheckoutRoute(
                                        restaurantName:
                                            cartItems.first.restaurantId ?? '',
                                        cartItems: cartItems
                                            .map((item) => {
                                                  'name': item.name,
                                                  'price': item.price,
                                                  'description':
                                                      item.description,
                                                  'quantity': item.quantity,
                                                })
                                            .toList(),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cartItems.isEmpty
                                  ? Colors.grey
                                  : UIColors.orange,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21),
                              ),
                            ),
                            child: Text(
                              'Passer la commande',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// Provider pour le repository du panier
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(remoteDataSource: CartRemoteDataSourceImpl());
});
