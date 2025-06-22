import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/card/data/datasources/cart_remote_data_source.dart';
import 'package:liya/modules/restaurant/features/card/domain/entities/cart_item.dart';
import 'package:liya/modules/restaurant/features/card/domain/repositories/cart_repository.dart';
import 'package:liya/routes/app_router.gr.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';

// Provider pour le repository du panier
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(remoteDataSource: CartRemoteDataSourceImpl());
});

// Stream provider pour observer les changements du panier en temps réel
final cartItemsStreamProvider = StreamProvider<List<CartItem>>((ref) {
  final cartRemoteDataSource = CartRemoteDataSourceImpl();
  final userDetailsJson =
  singleton<LocalStorageFactory>().getUserDetails();
  final userDetails = userDetailsJson is String
      ? jsonDecode(userDetailsJson)
      : userDetailsJson;
  final phoneNumber = userDetails['phoneNumber'] ?? '';
  return cartRemoteDataSource.watchCartItems(phoneNumber);
});

class HomeRestaurantHeader extends ConsumerWidget {
  const HomeRestaurantHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItemsAsyncValue = ref.watch(cartItemsStreamProvider);
    final userDetailsLocation =
    singleton<LocalStorageFactory>().getUserLocation();
    final address = userDetailsLocation['address'] ?? '';

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$address",
                style: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        context.router.push(CartRoute());
                      },
                    ),
                    cartItemsAsyncValue.when(
                      data: (cartItems) {
                        if (cartItems.isEmpty) return SizedBox.shrink();

                        int totalItems = cartItems.fold(
                          0,
                          (sum, item) => sum + item.quantity,
                        );

                        return Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$totalItems',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => SizedBox.shrink(),
                      error: (_, __) => SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
