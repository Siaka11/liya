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
// Remplacer les providers MySQL par les providers Firebase
import '../../application/popular_dishes_firebase_provider.dart';
import '../../application/restaurants_firebase_provider.dart';
import '../../application/new_dishes_firebase_provider.dart';
import '../../application/categories_firebase_provider.dart';
import '../widget/popular_dish_card.dart';
import '../widget/restaurant_card.dart';
import '../widget/restaurant_firebase_card.dart';
import 'package:liya/modules/restaurant/features/category/presentation/pages/dishes_by_category_page.dart';

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

    // Remplacer les providers MySQL par les providers Firebase
    final restaurantsFirebaseController =
        ref.read(restaurantsFirebaseProvider.notifier);
    final restaurantsFirebaseState = ref.watch(restaurantsFirebaseProvider);

    final popularDishesFirebaseController =
        ref.read(popularDishesFirebaseProvider.notifier);
    final popularDishesFirebaseState = ref.watch(popularDishesFirebaseProvider);

    // Nouveau provider pour les plats Firebase
    final newDishesFirebaseController =
        ref.read(newDishesFirebaseProvider.notifier);
    final newDishesFirebaseState = ref.watch(newDishesFirebaseProvider);

    // Categories provider
    final categoriesFirebaseController =
        ref.read(categoriesFirebaseProvider.notifier);
    final categoriesFirebaseState = ref.watch(categoriesFirebaseProvider);

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
      // Charger les nouveaux plats Firebase
      if (newDishesFirebaseState.dishes == null &&
          !newDishesFirebaseState.isLoading) {
        newDishesFirebaseController.loadNewDishes();
      }
      // Charger les catégories Firebase
      if (categoriesFirebaseState.categories == null &&
          !categoriesFirebaseState.isLoading) {
        categoriesFirebaseController.loadCategories();
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
                              child: Icon(Icons.arrow_forward_ios, size: 16),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          child: popularDishesFirebaseState.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : popularDishesFirebaseState.error != null
                                  ? Center(
                                      child: Text(
                                          popularDishesFirebaseState.error!))
                                  : popularDishesFirebaseState.dishes == null ||
                                          popularDishesFirebaseState
                                              .dishes!.isEmpty
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
                                                      popularDishesFirebaseState
                                                          .dishes!.length;
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
                                                          id: popularDishesFirebaseState
                                                              .dishes![i]['id'],
                                                          name:
                                                              popularDishesFirebaseState
                                                                      .dishes![
                                                                  i]['name'],
                                                          price:
                                                              popularDishesFirebaseState
                                                                  .dishes![i]
                                                                      ['price']
                                                                  .toString(),
                                                          imageUrl:
                                                              popularDishesFirebaseState
                                                                      .dishes![i]
                                                                  ['image_url'],
                                                          restaurantId:
                                                              popularDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'restaurant_id'],
                                                          description:
                                                              popularDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'description'],
                                                          // Paramètres de popularité
                                                          orderCount: popularDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'order_count'] ??
                                                              0,
                                                          rating: (popularDishesFirebaseState
                                                                          .dishes![i]
                                                                      [
                                                                      'rating'] ??
                                                                  0.0)
                                                              .toDouble(),
                                                          ratingCount:
                                                              popularDishesFirebaseState
                                                                          .dishes![i]
                                                                      [
                                                                      'rating_count'] ??
                                                                  0,
                                                          // Paramètres de promotion
                                                          isOnSale: popularDishesFirebaseState
                                                                      .dishes![i]
                                                                  [
                                                                  'is_on_sale'] ??
                                                              false,
                                                          originalPrice:
                                                              popularDishesFirebaseState
                                                                  .dishes![i][
                                                                      'original_price']
                                                                  ?.toDouble(),
                                                          discountPercentage:
                                                              popularDishesFirebaseState
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
                                                                  id: popularDishesFirebaseState
                                                                          .dishes![
                                                                      i]['id'],
                                                                  restaurantId:
                                                                      popularDishesFirebaseState
                                                                              .dishes![i]
                                                                          [
                                                                          'restaurant_id'],
                                                                  name: popularDishesFirebaseState
                                                                          .dishes![
                                                                      i]['name'],
                                                                  price: popularDishesFirebaseState
                                                                      .dishes![
                                                                          i][
                                                                          'price']
                                                                      .toString(),
                                                                  imageUrl: popularDishesFirebaseState
                                                                          .dishes![i]
                                                                      [
                                                                      'image_url'],
                                                                  rating: popularDishesFirebaseState
                                                                      .dishes![
                                                                          i][
                                                                          'rating']
                                                                      .toString(),
                                                                  description:
                                                                      popularDishesFirebaseState
                                                                              .dishes![i]
                                                                          [
                                                                          'description'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      if (i + 1 <
                                                          popularDishesFirebaseState
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
                                                              id: popularDishesFirebaseState
                                                                      .dishes![
                                                                  i + 1]['id'],
                                                              name: popularDishesFirebaseState
                                                                      .dishes![
                                                                  i + 1]['name'],
                                                              price: popularDishesFirebaseState
                                                                  .dishes![
                                                                      i + 1]
                                                                      ['price']
                                                                  .toString(),
                                                              imageUrl: popularDishesFirebaseState
                                                                          .dishes![
                                                                      i + 1]
                                                                  ['image_url'],
                                                              restaurantId:
                                                                  popularDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'restaurant_id'],
                                                              description:
                                                                  popularDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'description'],
                                                              // Paramètres de popularité
                                                              orderCount: popularDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'order_count'] ??
                                                                  0,
                                                              rating: (popularDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'rating'] ??
                                                                      0.0)
                                                                  .toDouble(),
                                                              ratingCount: popularDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'rating_count'] ??
                                                                  0,
                                                              // Paramètres de promotion
                                                              isOnSale: popularDishesFirebaseState
                                                                              .dishes![
                                                                          i + 1]
                                                                      [
                                                                      'is_on_sale'] ??
                                                                  false,
                                                              originalPrice:
                                                                  popularDishesFirebaseState
                                                                      .dishes![
                                                                          i + 1]
                                                                          [
                                                                          'original_price']
                                                                      ?.toDouble(),
                                                              discountPercentage:
                                                                  popularDishesFirebaseState
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
                                                                      id: popularDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'id'],
                                                                      restaurantId:
                                                                          popularDishesFirebaseState.dishes![i + 1]
                                                                              [
                                                                              'restaurant_id'],
                                                                      name: popularDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'name'],
                                                                      price: popularDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'price'],
                                                                      imageUrl: popularDishesFirebaseState.dishes![i +
                                                                              1]
                                                                          [
                                                                          'image_url'],
                                                                      rating: popularDishesFirebaseState
                                                                          .dishes![
                                                                              i + 1]
                                                                              [
                                                                              'rating']
                                                                          .toString(),
                                                                      description:
                                                                          popularDishesFirebaseState.dishes![i + 1]
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
                  // Section Catégories
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Catégories",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        categoriesFirebaseState.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : categoriesFirebaseState.error != null
                                ? Center(
                                    child: Text(categoriesFirebaseState.error!))
                                : categoriesFirebaseState.categories == null ||
                                        categoriesFirebaseState
                                            .categories!.isEmpty
                                    ? Center(
                                        child:
                                            Text("Aucune catégorie disponible"))
                                    : SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: categoriesFirebaseState
                                              .categories!.length,
                                          itemBuilder: (context, index) {
                                            final category =
                                                categoriesFirebaseState
                                                    .categories![index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DishesByCategoryPage(
                                                        categoryId:
                                                            category['id'],
                                                        categoryName:
                                                            category['name'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 100,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 70,
                                                        height: 70,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(35),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[300]!,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(35),
                                                          child: category['imageUrl'] !=
                                                                      null &&
                                                                  category[
                                                                          'imageUrl']
                                                                      .isNotEmpty
                                                              ? Image.network(
                                                                  category[
                                                                      'imageUrl'],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 70,
                                                                  height: 70,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              35),
                                                                      color: Color(int.parse(category['color']?.replaceFirst(
                                                                              '#',
                                                                              '0xFF') ??
                                                                          '0xFFFF6B6B')),
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              35),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/img/basilique.png', // Image par défaut
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width:
                                                                            70,
                                                                        height:
                                                                            70,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  loadingBuilder:
                                                                      (context,
                                                                          child,
                                                                          loadingProgress) {
                                                                    if (loadingProgress ==
                                                                        null)
                                                                      return child;
                                                                    return Container(
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                          value: loadingProgress.expectedTotalBytes != null
                                                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                              : null,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                )
                                                              : Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            35),
                                                                    color: Color(int.parse((category['color'] ??
                                                                            '#FF6B6B')
                                                                        .replaceFirst(
                                                                            '#',
                                                                            '0xFF'))),
                                                                  ),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            35),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/img/basilique.png', // Image par défaut
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 70,
                                                                      height:
                                                                          70,
                                                                    ),
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        category['name'],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        '${category['dishes_count']} plats',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
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
                            const Text(
                              "Restaurants",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                // Dropdown pour le tri des restaurants
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<RestaurantSortOption>(
                                    value: restaurantsFirebaseState.sortOption,
                                    underline: Container(),
                                    icon: const Icon(Icons.sort, size: 16),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                    items: RestaurantSortOption.values
                                        .map((option) {
                                      return DropdownMenuItem<
                                          RestaurantSortOption>(
                                        value: option,
                                        child: Text(
                                          option.label,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged:
                                        (RestaurantSortOption? newOption) {
                                      if (newOption != null) {
                                        restaurantsFirebaseController
                                            .changeSortOption(newOption);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    context.router.push(AllRestaurantsRoute());
                                  },
                                  child:
                                      Icon(Icons.arrow_forward_ios, size: 16),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        restaurantsFirebaseState.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : restaurantsFirebaseState.error != null
                                ? Center(
                                    child:
                                        Text(restaurantsFirebaseState.error!))
                                : restaurantsFirebaseState.restaurants ==
                                            null ||
                                        restaurantsFirebaseState
                                            .restaurants!.isEmpty
                                    ? Center(
                                        child:
                                            Text("Aucun restaurant disponible"))
                                    : SizedBox(
                                        height:
                                            200, // Hauteur fixe pour la section
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: restaurantsFirebaseState
                                              .restaurants!.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16),
                                              child: Container(
                                                width: 300,
                                                child: RestaurantFirebaseCard(
                                                  width: 300.0,
                                                  restaurant:
                                                      restaurantsFirebaseState
                                                          .restaurants![index],
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RestaurantDetailPage(
                                                          coverImage:
                                                              restaurantsFirebaseState
                                                                          .restaurants![
                                                                      index][
                                                                  'cover_image'],
                                                          id: restaurantsFirebaseState
                                                                  .restaurants![
                                                              index]['id'],
                                                          name: restaurantsFirebaseState
                                                                  .restaurants![
                                                              index]['name'],
                                                          description:
                                                              restaurantsFirebaseState
                                                                              .restaurants![
                                                                          index]
                                                                      [
                                                                      'description'] ??
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
                                /* IconButton(
                                  onPressed: () {
                                    newDishesFirebaseController.refresh();
                                  },
                                  */ /*icon: const Icon(Icons.refresh, size: 20),
                                  tooltip: 'Actualiser',*/ /*
                                ),*/
                                TextButton(
                                  onPressed: () {
                                    context.router.push(AllDishesRoute());
                                  },
                                  child:
                                      Icon(Icons.arrow_forward_ios, size: 16),
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
