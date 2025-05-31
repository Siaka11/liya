import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/popular_dish_card.dart';
import 'package:liya/modules/restaurant/features/like/application/like_provider.dart';
import 'package:liya/modules/restaurant/features/like/domain/entities/liked_dish.dart';
import 'package:liya/routes/app_router.gr.dart';

@RoutePage(name: 'LikedDishesRoute')
class LikedDishesPage extends ConsumerWidget {
  const LikedDishesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    final likedDishesAsync = ref.watch(getLikedDishesProvider(phoneNumber));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes plats favoris'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: likedDishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: ${error.toString()}'),
        ),
        data: (likedDishes) {
          if (likedDishes.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez pas encore liké de plats'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: (likedDishes.length + 1) ~/ 2,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: PopularDishCard(
                        id: likedDishes[i * 2].id,
                        name: likedDishes[i * 2].name,
                        price: likedDishes[i * 2].price.toString(),
                        imageUrl: likedDishes[i * 2].imageUrl,
                        restaurantId: likedDishes[i * 2].restaurantId,
                        description: likedDishes[i * 2].description,
                        userId: phoneNumber,
                        onAddToCart: () {
                          // Add to cart logic
                        },
                      ),
                    ),
                    if (i * 2 + 1 < likedDishes.length)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Expanded(
                          child: PopularDishCard(
                            id: likedDishes[i * 2 + 1].id,
                            name: likedDishes[i * 2 + 1].name,
                            price: likedDishes[i * 2 + 1].price.toString(),
                            imageUrl: likedDishes[i * 2 + 1].imageUrl,
                            restaurantId: likedDishes[i * 2 + 1].restaurantId,
                            description: likedDishes[i * 2 + 1].description,
                            userId: phoneNumber,
                            onAddToCart: () {
                              // Add to cart logic
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
