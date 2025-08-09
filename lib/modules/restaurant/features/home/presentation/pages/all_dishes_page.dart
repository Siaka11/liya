import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';
import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../../../../routes/app_router.gr.dart';
import '../../application/popular_dishes_firebase_provider.dart';
import '../widget/popular_dish_card.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';

@RoutePage()
class AllDishesPage extends ConsumerWidget {
  const AllDishesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesState = ref.watch(allDishesFirebaseProvider);
    final dishesController = ref.read(allDishesFirebaseProvider.notifier);

    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    // Charger tous les plats si pas encore chargés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishesState.dishes == null && !dishesState.isLoading) {
        (dishesController as AllDishesFirebaseNotifier).loadAllDishes();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les plats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dishesController.refresh(),
          ),
        ],
      ),
      body: dishesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dishesState.error != null
              ? Center(child: Text('Erreur: ${dishesState.error}'))
              : dishesState.dishes == null || dishesState.dishes!.isEmpty
                  ? const Center(child: Text('Aucun plat disponible'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: dishesState.dishes!.length,
                      itemBuilder: (context, index) {
                        final dish = dishesState.dishes![index];
                        return ModernDishCard(
                          id: dish['id'],
                          name: dish['name'],
                          price: dish['price'].toString(),
                          imageUrl: dish['image_url'],
                          restaurantId: dish['restaurant_id'],
                          description: dish['description'],
                          isOnSale: dish['is_on_sale'] ?? false,
                          originalPrice:
                              (dish['original_price'] ?? dish['price'])
                                  .toDouble(),
                          discountPercentage:
                              dish['discount_percentage'] ?? 0.0,
                          orderCount: dish['order_count'] ?? 0,
                          rating: (dish['rating'] ?? 0.0).toDouble(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DishDetailPage(
                                  id: dish['id'],
                                  restaurantId: dish['restaurant_id'],
                                  name: dish['name'],
                                  price: dish['price'].toString(),
                                  imageUrl: dish['image_url'],
                                  rating: dish['rating'].toString(),
                                  description: dish['description'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
