import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/all_restaurants_provider.dart';
import '../widget/restaurant_card.dart';

@RoutePage()
class AllRestaurantsPage extends ConsumerWidget {
  const AllRestaurantsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(allRestaurantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tous les restaurants")),
      body: restaurantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (restaurants) => ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantCard(
              restaurant: restaurant,
              onTap: () {
                // Navigue vers la page de détail du restaurant si besoin
              },
            );
          },
        ),
      ),
    );
  }
}
