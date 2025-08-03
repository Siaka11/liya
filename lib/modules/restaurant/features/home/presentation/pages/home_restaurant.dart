import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/filter_section.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/home_restaurant_header.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/navigation_footer.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
// Import des nouveaux widgets modernes
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';

import '../../../../../../routes/app_router.gr.dart';
import '../../../../../home/domain/entities/home_option.dart';
import '../../application/pupular_dish_controller_provider.dart';
import '../../application/restaurant_controller_provider.dart';
import '../../application/new_dishes_firebase_provider.dart';
import '../widget/popular_dish_card.dart';
import '../widget/restaurant_card.dart';

@RoutePage(name: 'HomeRestaurantRoute')
class HomeRestaurantPage extends ConsumerWidget {
  final HomeOption option;

  const HomeRestaurantPage({super.key, required this.option});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';
    final controller = ref.read(restaurantControllerProvider.notifier);
    final restaurantState = ref.watch(restaurantControllerProvider);
    final popularDishController =
        ref.read(popularDishControllerProvider.notifier);
    final popularDishState = ref.watch(popularDishControllerProvider);

    // Nouveau provider pour les plats Firebase
    final newDishesFirebaseController =
        ref.read(newDishesFirebaseProvider.notifier);
    final newDishesFirebaseState = ref.watch(newDishesFirebaseProvider);

    // Charger les données uniquement au premier rendu si non chargé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantState.restaurants == null && !restaurantState.isLoading) {
        controller.loadRestaurants();
      }
      if (popularDishState.popularDishes == null &&
          !popularDishState.isLoading) {
        popularDishController.loadPopularDishes();
      }
      // Charger les nouveaux plats Firebase
      if (newDishesFirebaseState.dishes == null &&
          !newDishesFirebaseState.isLoading) {
        newDishesFirebaseController.loadNewDishes();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête personnalisé
                  HomeRestaurantHeader(),
                  // Barre de recherche
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        context.router.push(SearchRoute());
                      },
                      child: TextField(
                        enabled: false, // Désactive la saisie directe
                        decoration: InputDecoration(
                          hintText: "Rechercher",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Filtres régionaux
                  FilterSection(),
                  // Section Populaires
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Populaires",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                context.router.push(AllDishesRoute());
                              },
                              child: Text("Voir tout"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          child: popularDishState.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : popularDishState.error != null
                                  ? Center(child: Text(popularDishState.error!))
                                  : popularDishState.popularDishes == null ||
                                          popularDishState
                                              .popularDishes!.isEmpty
                                      ? Center(
                                          child: Text(
                                              "Aucun plat populaire disponible"))
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      popularDishState
                                                          .popularDishes!
                                                          .length;
                                                  i += 2)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      // Utiliser ModernDishCard au lieu de PopularDishCard
                                                      Container(
                                                        width: 160,
                                                        child: ModernDishCard(
                                                          id: popularDishState
                                                              .popularDishes![i]
                                                              .id,
                                                          name: popularDishState
                                                              .popularDishes![i]
                                                              .name,
                                                          price: popularDishState
                                                              .popularDishes![i]
                                                              .price,
                                                          imageUrl:
                                                              popularDishState
                                                                  .popularDishes![
                                                                      i]
                                                                  .imageUrl,
                                                          restaurantId:
                                                              popularDishState
                                                                  .popularDishes![
                                                                      i]
                                                                  .restaurantId,
                                                          description:
                                                              popularDishState
                                                                  .popularDishes![
                                                                      i]
                                                                  .description,
                                                          onTap: () {
                                                            // Navigation vers la page de détail du plat
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DishDetailPage(
                                                                  id: popularDishState
                                                                      .popularDishes![
                                                                          i]
                                                                      .id,
                                                                  restaurantId:
                                                                      popularDishState
                                                                          .popularDishes![
                                                                              i]
                                                                          .restaurantId,
                                                                  name: popularDishState
                                                                      .popularDishes![
                                                                          i]
                                                                      .name,
                                                                  price: popularDishState
                                                                      .popularDishes![
                                                                          i]
                                                                      .price,
                                                                  imageUrl: popularDishState
                                                                      .popularDishes![
                                                                          i]
                                                                      .imageUrl,
                                                                  rating: '0.0',
                                                                  description:
                                                                      popularDishState
                                                                          .popularDishes![
                                                                              i]
                                                                          .description,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      if (i + 1 <
                                                          popularDishState
                                                              .popularDishes!
                                                              .length)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Container(
                                                            width: 160,
                                                            child:
                                                                ModernDishCard(
                                                              id: popularDishState
                                                                  .popularDishes![
                                                                      i + 1]
                                                                  .id,
                                                              name: popularDishState
                                                                  .popularDishes![
                                                                      i + 1]
                                                                  .name,
                                                              price: popularDishState
                                                                  .popularDishes![
                                                                      i + 1]
                                                                  .price,
                                                              imageUrl:
                                                                  popularDishState
                                                                      .popularDishes![
                                                                          i + 1]
                                                                      .imageUrl,
                                                              restaurantId:
                                                                  popularDishState
                                                                      .popularDishes![
                                                                          i + 1]
                                                                      .restaurantId,
                                                              description:
                                                                  popularDishState
                                                                      .popularDishes![
                                                                          i + 1]
                                                                      .description,
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            DishDetailPage(
                                                                      id: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .id,
                                                                      restaurantId: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .restaurantId,
                                                                      name: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .name,
                                                                      price: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .price,
                                                                      imageUrl: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .imageUrl,
                                                                      rating:
                                                                          '0.0',
                                                                      description: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .description,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                        ),
                      ],
                    ),
                  ),
                  // Section Restaurants
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Restaurants",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                context.router.push(AllRestaurantsRoute());
                              },
                              child: Text("Voir tout"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        restaurantState.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : restaurantState.error != null
                                ? Center(child: Text(restaurantState.error!))
                                : restaurantState.restaurants == null ||
                                        restaurantState.restaurants!.isEmpty
                                    ? Center(
                                        child:
                                            Text("Aucun restaurant disponible"))
                                    : SizedBox(
                                        height:
                                            200, // Hauteur fixe pour la section
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: restaurantState
                                              .restaurants!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16),
                                              child: Container(
                                                width: 300,
                                                child: RestaurantCard(
                                                  width: 300.0,
                                                  restaurant: restaurantState
                                                      .restaurants![index],
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RestaurantDetailPage(
                                                          coverImage:
                                                              restaurantState
                                                                  .restaurants![
                                                                      index]
                                                                  .coverImage,
                                                          id: restaurantState
                                                              .restaurants![
                                                                  index]
                                                              .id,
                                                          name: restaurantState
                                                              .restaurants![
                                                                  index]
                                                              .name,
                                                          description: restaurantState
                                                                  .restaurants![
                                                                      index]
                                                                  .description ??
                                                              '',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                      ],
                    ),
                  ),
                  // Les plats - Section Nouveaux plats avec Firebase
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Nouveaux plats",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    newDishesFirebaseController.refresh();
                                  },
                                  icon: const Icon(Icons.refresh, size: 20),
                                  tooltip: 'Actualiser',
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.router.push(AllDishesRoute());
                                  },
                                  child: Text("Voir tout"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          child: newDishesFirebaseState.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : newDishesFirebaseState.error != null
                                  ? Center(
                                      child: Column(
                                        children: [
                                          Text(newDishesFirebaseState.error!),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              newDishesFirebaseController
                                                  .refresh();
                                            },
                                            child: const Text('Réessayer'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : newDishesFirebaseState.dishes == null ||
                                          newDishesFirebaseState.dishes!.isEmpty
                                      ? Center(
                                          child: Column(
                                            children: [
                                              const Text(
                                                  "Aucun nouveau plat disponible"),
                                              const SizedBox(height: 8),
                                              Text(
                                                "État: ${newDishesFirebaseState.isLoading ? 'Chargement...' : 'Terminé'}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  newDishesFirebaseController
                                                      .refresh();
                                                },
                                                child: const Text('Actualiser'),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      newDishesFirebaseState
                                                          .dishes!.length;
                                                  i += 2)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Row(
                                                    children: [
                                                      // Premier plat
                                                      Container(
                                                        width: 160,
                                                        child: ModernDishCard(
                                                          id: newDishesFirebaseState
                                                              .dishes![i]['id'],
                                                          name:
                                                              newDishesFirebaseState
                                                                      .dishes![
                                                                  i]['name'],
                                                          price:
                                                              newDishesFirebaseState
                                                                  .dishes![i]
                                                                      ['price']
                                                                  .toString(),
                                                          imageUrl:
                                                              newDishesFirebaseState
                                                                      .dishes![i]
                                                                  ['image_url'],
                                                          restaurantId:
                                                              newDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'restaurant_id'],
                                                          description:
                                                              newDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'description'],
                                                          isOnSale: newDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'is_on_sale'] ??
                                                              false,
                                                          originalPrice:
                                                              newDishesFirebaseState
                                                                  .dishes![i][
                                                                      'original_price']
                                                                  ?.toDouble(),
                                                          discountPercentage:
                                                              newDishesFirebaseState
                                                                  .dishes![i][
                                                                      'discount_percentage']
                                                                  ?.toDouble(),
                                                          onTap: () {
                                                            // Navigation vers la page de détail du plat
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DishDetailPage(
                                                                  id: newDishesFirebaseState
                                                                          .dishes![
                                                                      i]['id'],
                                                                  restaurantId:
                                                                      newDishesFirebaseState
                                                                              .dishes![i]
                                                                          [
                                                                          'restaurant_id'],
                                                                  name: newDishesFirebaseState
                                                                          .dishes![
                                                                      i]['name'],
                                                                  price: newDishesFirebaseState
                                                                      .dishes![
                                                                          i][
                                                                          'price']
                                                                      .toString(),
                                                                  imageUrl: newDishesFirebaseState
                                                                          .dishes![i]
                                                                      [
                                                                      'image_url'],
                                                                  rating: newDishesFirebaseState
                                                                      .dishes![
                                                                          i][
                                                                          'rating']
                                                                      .toString(),
                                                                  description:
                                                                      newDishesFirebaseState
                                                                              .dishes![i]
                                                                          [
                                                                          'description'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      // Deuxième plat (si disponible)
                                                      if (i + 1 <
                                                          newDishesFirebaseState
                                                              .dishes!.length)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Container(
                                                            width: 160,
                                                            child:
                                                                ModernDishCard(
                                                              id: newDishesFirebaseState
                                                                      .dishes![
                                                                  i + 1]['id'],
                                                              name: newDishesFirebaseState
                                                                      .dishes![
                                                                  i + 1]['name'],
                                                              price: newDishesFirebaseState
                                                                  .dishes![
                                                                      i + 1]
                                                                      ['price']
                                                                  .toString(),
                                                              imageUrl: newDishesFirebaseState
                                                                          .dishes![
                                                                      i + 1]
                                                                  ['image_url'],
                                                              restaurantId:
                                                                  newDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'restaurant_id'],
                                                              description:
                                                                  newDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'description'],
                                                              isOnSale: newDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'is_on_sale'] ??
                                                                  false,
                                                              originalPrice:
                                                                  newDishesFirebaseState
                                                                      .dishes![
                                                                          i + 1]
                                                                          [
                                                                          'original_price']
                                                                      ?.toDouble(),
                                                              discountPercentage:
                                                                  newDishesFirebaseState
                                                                      .dishes![
                                                                          i + 1]
                                                                          [
                                                                          'discount_percentage']
                                                                      ?.toDouble(),
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            DishDetailPage(
                                                                      id: newDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'id'],
                                                                      restaurantId:
                                                                          newDishesFirebaseState.dishes![i + 1]
                                                                              [
                                                                              'restaurant_id'],
                                                                      name: newDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'name'],
                                                                      price: newDishesFirebaseState
                                                                          .dishes![
                                                                              i + 1]
                                                                              [
                                                                              'price']
                                                                          .toString(),
                                                                      imageUrl: newDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'image_url'],
                                                                      rating: newDishesFirebaseState
                                                                          .dishes![
                                                                              i + 1]
                                                                              [
                                                                              'rating']
                                                                          .toString(),
                                                                      description:
                                                                          newDishesFirebaseState.dishes![i + 1]
                                                                              [
                                                                              'description'],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                  /*Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Plats",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                context.router.push(AllRestaurantsRoute());
                              },
                              child: Text("Voir tout"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        if (restaurantState.isLoading)
                          Center(child: CircularProgressIndicator())
                        else if (restaurantState.error != null)
                          Center(child: Text(restaurantState.error!))
                        else if (restaurantState.restaurants == null ||
                              restaurantState.restaurants!.isEmpty)
                            Center(child: Text("Aucun plat disponible"))
                          else
                            Column(
                              children: restaurantState.restaurants!.map((restaurant) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: RestaurantCard(
                                    width: 300.0,
                                    restaurant: restaurant,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RestaurantDetailPage(
                                            coverImage: restaurant.coverImage,
                                            id: restaurant.id,
                                            name: restaurant.name,
                                            description: restaurant.description ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                      ],
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          // Bouton flottant de commande moderne
          const FloatingOrderButton(),
        ],
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}
