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
                                                          sodas: popularDishState
                                                              .popularDishes![i]
                                                              .sodas,
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
                                                                  sodas: popularDishState
                                                                      .popularDishes![
                                                                          i]
                                                                      .sodas,
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
                                                                  left: 4),
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
                                                              sodas: popularDishState
                                                                  .popularDishes![
                                                                      i + 1]
                                                                  .sodas,
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
                                                                      sodas: popularDishState
                                                                          .popularDishes![i +
                                                                              1]
                                                                          .sodas,
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
                  const SizedBox(height: 10), // Espace pour le bouton flottant
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
                        SizedBox(height: 16),
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
                  const SizedBox(height: 100), // Espace pour le bouton flottant
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
