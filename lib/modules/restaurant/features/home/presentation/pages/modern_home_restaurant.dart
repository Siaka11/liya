import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import 'package:liya/core/ui/components/notification_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/navigation_footer.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_restaurant_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/modern_dish_detail_page.dart';

import '../../../../../../routes/app_router.gr.dart';
import '../../../../../home/domain/entities/home_option.dart';
// Remplacer les providers MySQL par les providers Firebase
import '../../application/popular_dishes_firebase_provider.dart';
import '../../application/restaurants_firebase_provider.dart';
import '../widget/restaurant_card.dart';
import '../widget/restaurant_firebase_card.dart';

@RoutePage(name: 'ModernHomeRestaurantRoute')
class ModernHomeRestaurantPage extends ConsumerWidget {
  final HomeOption option;

  const ModernHomeRestaurantPage({super.key, required this.option});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    // Remplacer les providers MySQL par les providers Firebase
    final restaurantsFirebaseController =
        ref.read(restaurantsFirebaseProvider.notifier);
    final restaurantsFirebaseState = ref.watch(restaurantsFirebaseProvider);

    final popularDishesFirebaseController =
        ref.read(popularDishesFirebaseProvider.notifier);
    final popularDishesFirebaseState = ref.watch(popularDishesFirebaseProvider);

    // Charger les données uniquement au premier rendu si non chargé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantsFirebaseState.restaurants == null &&
          !restaurantsFirebaseState.isLoading) {
        restaurantsFirebaseController.loadRestaurants();
      }
      if (popularDishesFirebaseState.dishes == null &&
          !popularDishesFirebaseState.isLoading) {
        popularDishesFirebaseController.loadPopularDishes();
      }
    });

    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête moderne
                  _buildHeader(context),

                  // Barre de recherche
                  _buildSearchBar(context),

                  // Section plats populaires
                  _buildPopularDishesSection(
                      context, popularDishesFirebaseState, phoneNumber),

                  // Section restaurants
                  _buildRestaurantsSection(context, restaurantsFirebaseState),

                  const SizedBox(height: 100), // Espace pour le bouton flottant
                ],
              ),
            ),
          ),

          // Bouton flottant de commande
          const FloatingOrderButton(),
        ],
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: UIColors.orange,
                child: const Icon(Icons.restaurant, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurants',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Découvrez les meilleurs restaurants',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              NotificationAppBarButton(
                backgroundColor: Colors.transparent,
                iconColor: Colors.grey[700],
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigation vers les favoris
                },
                icon: const Icon(Icons.favorite_border),
                color: Colors.grey,
              ),
              IconButton(
                onPressed: () {
                  context.router.push(TestBeveragesRoute());
                },
                icon: const Icon(Icons.local_drink),
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () {
          context.router.push(SearchRoute());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                "Rechercher un restaurant ou un plat...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularDishesSection(BuildContext context,
      PopularDishesFirebaseState popularDishesState, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Plats populaires",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.router.push(AllDishesRoute());
                },
                child: const Text("Voir tout"),
                style: TextButton.styleFrom(
                  foregroundColor: UIColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (popularDishesState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (popularDishesState.error != null)
            Center(child: Text(popularDishesState.error!))
          else if (popularDishesState.dishes == null ||
              popularDishesState.dishes!.isEmpty)
            const Center(child: Text("Aucun plat populaire disponible"))
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularDishesState.dishes!.length,
                itemBuilder: (context, index) {
                  final dish = popularDishesState.dishes![index];
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 16),
                    child: ModernDishCard(
                      id: dish['id'],
                      name: dish['name'],
                      price: dish['price'],
                      imageUrl: dish['image_url'],
                      restaurantId: dish['restaurant_id'],
                      description: dish['description'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModernDishDetailPage(
                              id: dish['id'],
                              restaurantId: dish['restaurant_id'],
                              name: dish['name'],
                              price: dish['price'],
                              imageUrl: dish['image_url'],
                              rating: dish['rating'].toString(),
                              description: dish['description'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsSection(
      BuildContext context, RestaurantsFirebaseState restaurantsState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Restaurants",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (restaurantsState.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (restaurantsState.error != null)
            Center(child: Text(restaurantsState.error!))
          else if (restaurantsState.restaurants == null ||
              restaurantsState.restaurants!.isEmpty)
            const Center(child: Text("Aucun restaurant disponible"))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: restaurantsState.restaurants!.length,
              itemBuilder: (context, index) {
                final restaurant = restaurantsState.restaurants![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RestaurantFirebaseCard(
                    width: double.infinity,
                    restaurant: restaurant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModernRestaurantDetailPage(
                            coverImage: restaurant['cover_image'],
                            id: restaurant['id'],
                            name: restaurant['name'],
                            description: restaurant['description'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
