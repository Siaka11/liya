import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/dish_card_simple.dart';
import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/singletons.dart';
import '../../../../../../routes/app_router.gr.dart';
import '../../application/all_dishes_provider.dart';
import '../widget/popular_dish_card.dart';

@RoutePage()
class AllDishesPage extends ConsumerWidget {
  const AllDishesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(allDishesProvider);
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Tous les plats")),
      body: dishesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (dishes) => ListView.builder(
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return InkWell(
              onTap: () {
                context.router.push(DishDetailRoute(
                  id: dish.id,
                  restaurantId: dish.restaurantId,
                  name: dish.name,
                  price: dish.price,
                  imageUrl: dish.imageUrl,
                  rating: '0.0',
                  description: dish.description,
                ));
              },
              child: DishCardSimple(
                dish: dish,
                userId: phoneNumber,
              ),
            );
          },
        ),
      ),
    );
  }
}
