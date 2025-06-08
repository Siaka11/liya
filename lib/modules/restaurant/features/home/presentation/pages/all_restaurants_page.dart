import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import '../../application/all_restaurants_provider.dart';
import '../widget/restaurant_card.dart';
import '../../../../../../core/routes/app_router.dart';

@RoutePage()
class AllRestaurantsPage extends ConsumerWidget {
  const AllRestaurantsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(allRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tous les restaurants",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: restaurantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (restaurants) => ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantCard(
              width: MediaQuery.of(context).size.width,
              restaurant: restaurant,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantDetailPage(
                          id: restaurant.id,
                          name: restaurant.name,
                          description: restaurant.description ?? '',
                          coverImage: restaurant.coverImage,
                        ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
