import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/filter_section.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/home_restaurant_header.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/navigation_footer.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';

import '../../../../../../core/routes/app_router.dart';
import '../../../../../home/domain/entities/home_option.dart';
import '../../application/pupular_dish_controller_provider.dart';
import '../../application/restaurant_controller_provider.dart';
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

    // Charger les données uniquement au premier rendu si non chargé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantState.restaurants == null && !restaurantState.isLoading) {
        controller.loadRestaurants();
      }
      if (popularDishState.popularDishes == null &&
          !popularDishState.isLoading) {
        popularDishController.loadPopularDishes();
      }
    });

    return Scaffold(
      body: SafeArea(
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
                child: TextField(
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
                      // Hauteur fixe pour la section populaire
                      child: popularDishState.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : popularDishState.error != null
                              ? Center(child: Text(popularDishState.error!))
                              : popularDishState.popularDishes == null ||
                                      popularDishState.popularDishes!.isEmpty
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
                                                      .popularDishes!.length;
                                              i += 2)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Row(
                                                children: [
                                                  PopularDishCard(
                                                    id: popularDishState
                                                        .popularDishes![i].id,
                                                    name: popularDishState
                                                        .popularDishes![i].name,
                                                    price: popularDishState
                                                        .popularDishes![i]
                                                        .price,
                                                    imageUrl: popularDishState
                                                        .popularDishes![i]
                                                        .imageUrl,
                                                    restaurantId:
                                                        popularDishState
                                                            .popularDishes![i]
                                                            .restaurantId,
                                                    description:
                                                        popularDishState
                                                            .popularDishes![i]
                                                            .description,
                                                    sodas:
                                                    popularDishState
                                                        .popularDishes![i]
                                                        .sodas,
                                                    userId: phoneNumber,
                                                    onAddToCart: () {
                                                      print(
                                                          "Ajouté au panier : ${popularDishState.popularDishes![i].name} (Restaurant: ${popularDishState.popularDishes![i].restaurantId})");
                                                    },
                                                  ),
                                                  if (i + 1 <
                                                      popularDishState
                                                          .popularDishes!
                                                          .length)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4),
                                                      child: PopularDishCard(
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
                                                        sodas:
                                                        popularDishState
                                                            .popularDishes![
                                                        i + 1]
                                                            .sodas,
                                                        userId: phoneNumber,
                                                        onAddToCart: () {
                                                          print(
                                                              "Ajouté au panier : ${popularDishState.popularDishes![i + 1].name} (Restaurant: ${popularDishState.popularDishes![i + 1].restaurantId})");
                                                        },
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
              SizedBox(height: 16),
              // Section Restaurants
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
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
                            context.router.push(const AllRestaurantsRoute());
                          },
                          child: Text("Voir tout"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    restaurantState.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : restaurantState.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Erreur : ${restaurantState.error}"),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () =>
                                          controller.loadRestaurants(),
                                      child: Text("Réessayer"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : restaurantState.restaurants == null
                                ? Center(child: CircularProgressIndicator())
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (int i = 0;
                                            i <
                                                restaurantState
                                                    .restaurants!.length;
                                            i += 2)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12),
                                            child: Row(
                                              children: [
                                                RestaurantCard(
                                                  width: 300.0,
                                                  restaurant: restaurantState
                                                      .restaurants![i],
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RestaurantDetailPage(
                                                              coverImage: restaurantState.restaurants![i]
                                                              .coverImage,
                                                          id: restaurantState
                                                              .restaurants![i]
                                                              .id,
                                                          name: restaurantState
                                                              .restaurants![i]
                                                              .name,
                                                          description: restaurantState
                                                                  .restaurants![
                                                                      i]
                                                                  .description ??
                                                              '',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (i + 1 <
                                                    restaurantState
                                                        .restaurants!.length)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: RestaurantCard(
                                                      width: 300.0,
                                                      restaurant:
                                                          restaurantState
                                                                  .restaurants![
                                                              i + 1],
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                RestaurantDetailPage(
                                                                  coverImage: restaurantState.restaurants![i]
                                                                      .coverImage,
                                                              id: restaurantState
                                                                  .restaurants![
                                                                      i + 1]
                                                                  .id, // Correction : i + 1
                                                              name: restaurantState
                                                                  .restaurants![
                                                                      i + 1]
                                                                  .name, // Correction : i + 1
                                                              description: restaurantState
                                                                      .restaurants![
                                                                          i + 1]
                                                                      .description ??
                                                                  '', // Correction : i + 1
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                  ],
                ),
              ),
              SizedBox(height: 16), // Un petit espace avant le footer
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}
