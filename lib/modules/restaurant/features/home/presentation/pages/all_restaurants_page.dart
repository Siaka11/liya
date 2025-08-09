import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:liya/core/ui/components/notification_button.dart';
import '../../application/restaurants_firebase_provider.dart';
import '../widget/restaurant_firebase_card.dart';

@RoutePage()
class AllRestaurantsPage extends ConsumerWidget {
  const AllRestaurantsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsState = ref.watch(restaurantsFirebaseProvider);
    final restaurantsController =
        ref.read(restaurantsFirebaseProvider.notifier);

    // Charger les restaurants si pas encore chargés
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantsState.restaurants == null && !restaurantsState.isLoading) {
        restaurantsController.loadRestaurants();
      }
    });

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
        actions: [
          NotificationAppBarButton(
            backgroundColor: Colors.transparent,
            iconColor: Colors.grey[700],
          ),
          // Dropdown pour le tri
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<RestaurantSortOption>(
              value: restaurantsState.sortOption,
              underline: Container(),
              icon: const Icon(Icons.sort, size: 16),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: RestaurantSortOption.values.map((option) {
                return DropdownMenuItem<RestaurantSortOption>(
                  value: option,
                  child: Text(
                    option.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (RestaurantSortOption? newOption) {
                if (newOption != null) {
                  restaurantsController.changeSortOption(newOption);
                }
              },
            ),
          ),
        ],
      ),
      body: restaurantsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurantsState.error != null
              ? Center(child: Text('Erreur: ${restaurantsState.error}'))
              : restaurantsState.restaurants == null ||
                      restaurantsState.restaurants!.isEmpty
                  ? const Center(child: Text('Aucun restaurant disponible'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: restaurantsState.restaurants!.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurantsState.restaurants![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RestaurantFirebaseCard(
                            width: MediaQuery.of(context).size.width,
                            restaurant: restaurant,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantDetailPage(
                                    coverImage: restaurant['cover_image'] ?? '',
                                    id: restaurant['id'],
                                    name: restaurant['name'],
                                    description:
                                        restaurant['description'] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
