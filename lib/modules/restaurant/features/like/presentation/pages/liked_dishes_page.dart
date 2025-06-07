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
import 'package:liya/core/providers.dart';
import 'package:liya/modules/restaurant/features/dish/presentation/widgets/dish_card.dart';

import '../../../../../../core/ui/theme/theme.dart';
import '../../../home/presentation/widget/navigation_footer.dart';

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

    if (phoneNumber.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Veuillez vous connecter pour voir vos favoris'),
        ),
      );
    }

    final likedDishesAsync = ref.watch(getLikedDishesProvider(phoneNumber));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes plats favoris", style: TextStyle(color: UIColors.orange)),
        leading: SizedBox(),
      ),
      body: likedDishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: ${error.toString()}'),
        ),
        data: (likedDishes) {
          if (likedDishes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun plat favori',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Likez vos plats préférés pour les retrouver ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: likedDishes.length,
            itemBuilder: (context, index) {
              final dish = likedDishes[index];
              return GestureDetector(
                onTap: () {
                  context.router.push(
                    DishDetailRoute(
                      id: dish.id,
                      restaurantId: dish.restaurantId,
                      name: dish.name,
                      price: dish.price.toString(),
                      imageUrl: dish.imageUrl,
                      rating: dish.rating.toString(),
                      description: dish.description,
                      sodas: dish.sodas
                    ),
                  );
                },
                child: DishCard(
                  id: dish.id,
                  name: dish.name,
                  price: dish.price.toString(),
                  imageUrl: dish.imageUrl,
                  description: dish.description,
                  rating: dish.rating,
                  userId: phoneNumber,
                  sodas: dish.sodas,
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}
