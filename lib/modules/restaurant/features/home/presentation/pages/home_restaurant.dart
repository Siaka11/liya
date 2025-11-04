import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Pour defaultTargetPlatform
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/filter_section.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/home_restaurant_header.dart';
import 'package:liya/modules/restaurant/features/home/presentation/widget/navigation_footer.dart';
// Import des nouveaux widgets modernes
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';
import 'package:liya/core/providers/guest_mode_provider.dart'; // Provider mode invité

import '../../../../../../routes/app_router.gr.dart';
import '../../../../../home/domain/entities/home_option.dart';
// Remplacer les providers MySQL par les providers Firebase
import '../../application/popular_dishes_firebase_provider.dart';
import '../../application/restaurants_firebase_provider.dart';
import '../../application/new_dishes_firebase_provider.dart';
import '../../application/categories_firebase_provider.dart';
import '../../application/most_ordered_dishes_firebase_provider.dart';
import '../widget/restaurant_firebase_card.dart';
import 'package:liya/modules/restaurant/features/category/presentation/pages/dishes_by_category_page.dart';

@RoutePage(name: 'HomeRestaurantRoute')
class HomeRestaurantPage extends ConsumerWidget {
  final HomeOption option;

  const HomeRestaurantPage({super.key, required this.option});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vérifier le mode invité
    final guestMode = ref.watch(guestModeProvider);

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

    // Provider pour les plats les plus commandés
    final mostOrderedDishesFirebaseController =
        ref.read(mostOrderedDishesFirebaseProvider.notifier);
    final mostOrderedDishesFirebaseState =
        ref.watch(mostOrderedDishesFirebaseProvider);

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
      // Charger les plats les plus commandés
      if (mostOrderedDishesFirebaseState.dishes == null &&
          !mostOrderedDishesFirebaseState.isLoading) {
        mostOrderedDishesFirebaseController.loadMostOrderedDishes();
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
                  
                  // Bannière d'invitation à s'inscrire (mode invité iOS uniquement)
                  if (guestMode.isGuestMode &&
                      defaultTargetPlatform == TargetPlatform.iOS)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildGuestModeBanner(context, ref),
                    ),
                  
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
                  // Section Nouveaux plats
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
                              "Populaires",
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
                                      : SizedBox(
                                          height: 220,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                popularDishesFirebaseState
                                                    .dishes!.length,
                                            itemBuilder: (context, index) {
                                              final dish =
                                                  popularDishesFirebaseState
                                                      .dishes![index];
                                              return Container(
                                                width: 160,
                                                margin: const EdgeInsets.only(
                                                    right: 16),
                                                child: ModernDishCard(
                                                  id: dish['id'],
                                                  name: dish['name'],
                                                  price:
                                                      dish['price'].toString(),
                                                  imageUrl: dish['image_url'],
                                                  restaurantId:
                                                      dish['restaurant_id'],
                                                  description:
                                                      dish['description'],
                                                  // Paramètres de popularité
                                                  orderCount:
                                                      dish['order_count'] ?? 0,
                                                  rating:
                                                      (dish['rating'] ?? 0.0)
                                                          .toDouble(),
                                                  ratingCount:
                                                      dish['rating_count'] ?? 0,
                                                  // Paramètres de promotion
                                                  isOnSale:
                                                      dish['is_on_sale'] ??
                                                          false,
                                                  originalPrice:
                                                      dish['original_price']
                                                          ?.toDouble(),
                                                  discountPercentage: dish[
                                                          'discount_percentage']
                                                      ?.toDouble(),
                                                  onTap: () {
                                                    // Navigation vers la page de détail du plat
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DishDetailPage(
                                                          id: dish['id'],
                                                          restaurantId: dish[
                                                              'restaurant_id'],
                                                          name: dish['name'],
                                                          price: dish['price']
                                                              .toString(),
                                                          imageUrl:
                                                              dish['image_url'],
                                                          rating: dish['rating']
                                                              .toString(),
                                                          description: dish[
                                                              'description'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Les plus commandés",
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
                          child: mostOrderedDishesFirebaseState.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : mostOrderedDishesFirebaseState.error != null
                                  ? Center(
                                      child: Text(mostOrderedDishesFirebaseState
                                          .error!))
                                  : mostOrderedDishesFirebaseState.dishes ==
                                              null ||
                                          mostOrderedDishesFirebaseState
                                              .dishes!.isEmpty
                                      ? Center(
                                          child: Text(
                                              "Aucun plat commandé disponible"))
                                      : SizedBox(
                                          height: 200,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                mostOrderedDishesFirebaseState
                                                    .dishes!.length,
                                            itemBuilder: (context, index) {
                                              final dish =
                                                  mostOrderedDishesFirebaseState
                                                      .dishes![index];
                                              return Container(
                                                width: 160,
                                                margin: const EdgeInsets.only(
                                                    right: 16),
                                                child: ModernDishCard(
                                                  id: dish['id'],
                                                  name: dish['name'],
                                                  price:
                                                      dish['price'].toString(),
                                                  imageUrl: dish['image_url'],
                                                  restaurantId:
                                                      dish['restaurant_id'],
                                                  description:
                                                      dish['description'],
                                                  // Paramètres de popularité
                                                  orderCount:
                                                      dish['order_count'] ?? 0,
                                                  rating:
                                                      (dish['rating'] ?? 0.0)
                                                          .toDouble(),
                                                  ratingCount:
                                                      dish['rating_count'] ?? 0,
                                                  // Paramètres de promotion
                                                  isOnSale:
                                                      dish['is_on_sale'] ??
                                                          false,
                                                  originalPrice:
                                                      dish['original_price']
                                                          ?.toDouble(),
                                                  discountPercentage: dish[
                                                          'discount_percentage']
                                                      ?.toDouble(),
                                                  onTap: () {
                                                    // Navigation vers la page de détail du plat
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DishDetailPage(
                                                          id: dish['id'],
                                                          restaurantId: dish[
                                                              'restaurant_id'],
                                                          name: dish['name'],
                                                          price: dish['price']
                                                              .toString(),
                                                          imageUrl:
                                                              dish['image_url'],
                                                          rating: dish['rating']
                                                              .toString(),
                                                          description: dish[
                                                              'description'],
                                                        ),
                                                      ),
                                                    );
                                                  },
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
          // Bouton flottant de commande moderne
          const FloatingOrderButton(),
        ],
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
  
  /// Crée une bannière pour inviter les utilisateurs invités à s'inscrire
  Widget _buildGuestModeBanner(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode invité actif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Inscrivez-vous pour commander',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Désactiver le mode invité et rediriger vers l'inscription
              ref.read(guestModeProvider.notifier).disableGuestMode();
              context.router.push(const AuthRoute());
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'S\'inscrire',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
