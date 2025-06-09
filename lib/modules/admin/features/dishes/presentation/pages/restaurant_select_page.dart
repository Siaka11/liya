import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

@RoutePage()
class RestaurantSelectPage extends StatelessWidget {
  const RestaurantSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste statique de restaurants (à remplacer plus tard par un provider dynamique)
    final restaurants = [
      {'id': '1', 'name': 'Restaurant 1'},
      {'id': '2', 'name': 'Restaurant 2'},
      {'id': '3', 'name': 'Restaurant 3'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Sélection du restaurant')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(
                restaurant['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                context.router
                    .push(DishListRoute(restaurantId: restaurant['id']!));
              },
            ),
          );
        },
      ),
    );
  }
}
