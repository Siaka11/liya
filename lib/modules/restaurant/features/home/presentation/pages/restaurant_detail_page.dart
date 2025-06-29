import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';

import '../../../../../../core/local_storage_factory.dart';
import '../../../../../../core/routes/app_router.dart';
import '../../../../../../core/singletons.dart';
import '../../../card/data/datasources/cart_remote_data_source.dart';
import '../../../card/domain/repositories/cart_repository.dart';
import '../../../card/domain/usecases/add_to_cart.dart';
import '../../application/dish_provider.dart';
import '../../application/selected_quantity_provider.dart';
import '../widget/dish_card.dart';
import 'dish_detail_page.dart';
import 'package:liya/modules/restaurant/features/card/presentation/pages/cart_page.dart';
// Import des nouveaux widgets modernes
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';

final addToCartProvider = Provider<AddToCart>((ref) {
  return AddToCart(
      CartRepositoryImpl(remoteDataSource: CartRemoteDataSourceImpl()));
});

@RoutePage(name: 'RestaurantDetailRoute')
class RestaurantDetailPage extends ConsumerWidget {
  final String id;
  final String name;
  final String description;
  final String coverImage;

  const RestaurantDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishController = ref.read(dishControllerProvider(id).notifier);
    final dishState = ref.watch(dishControllerProvider(id));
    final cartRepository =
        CartRepositoryImpl(remoteDataSource: CartRemoteDataSourceImpl());

    // Créer un StateProvider pour forcer le rafraîchissement
    final refreshKey = StateProvider((ref) => 0);
    final refreshCount = ref.watch(refreshKey);
    final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
    final userDetails = userDetailsJson is String
        ? jsonDecode(userDetailsJson)
        : userDetailsJson;
    final phoneNumber = userDetails['phoneNumber'] ?? '';

    List<dynamic> selectedDishes = [];
    double totalAmount = 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (dishState.dishes == null && !dishState.isLoading) {
        dishController.loadDishes(id);
      }
    });

    Future<int> getCartItemQuantity(String dishName) async {
      final userId = phoneNumber;
      print('DEBUG: Recherche du plat dans le panier: "$dishName"');
      final result = await cartRepository.getCartItems(userId);
      return result.fold(
        (failure) {
          print(
              'DEBUG: Erreur lors de la récupération du panier: ${failure.message}');
          return 0;
        },
        (cartItems) {
          print(
              'DEBUG: Nombre d\'articles dans le panier: ${cartItems.length}');
          for (var item in cartItems) {
            print(
                'DEBUG: Article dans le panier - Nom: "${item.name}", Quantité: ${item.quantity}');
            // Comparaison exacte des noms
            if (item.name.trim() == dishName.trim()) {
              print(
                  'DEBUG: ✓ Correspondance trouvée pour "$dishName" avec quantité: ${item.quantity}');
              return item.quantity;
            }
          }
          print('DEBUG: Aucun article trouvé pour le plat: "$dishName"');
          return 0;
        },
      );
    }

    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(coverImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 300),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(60)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.local_shipping,
                                color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Livraison 25-35 min',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          description,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Plats disponibles',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Affichage de la quantité sélectionnée
                        if (dishState.dishes != null)
                          ...dishState.dishes!.map((dish) {
                            final selectedQty = ref
                                .read(selectedQuantityProvider.notifier)
                                .getQuantity(dish.id ?? '');
                            return selectedQty > 0
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${dish.name} - Quantité sélectionnée : $selectedQty',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            ref
                                                .read(selectedQuantityProvider
                                                    .notifier)
                                                .setQuantity(dish.id ?? '', 0);
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink();
                          }).toList(),
                        dishState.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : dishState.error != null
                                ? Center(child: Text(dishState.error!))
                                : dishState.dishes == null ||
                                        dishState.dishes!.isEmpty
                                    ? Center(
                                        child: Text(
                                            "Aucun plat disponible pour ce restaurant"))
                                    : GridView.builder(
                                        key: ValueKey(refreshCount),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.75,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                        itemCount: dishState.dishes!.length,
                                        itemBuilder: (context, index) {
                                          final dish = dishState.dishes![index];
                                          return ModernDishCard(
                                            id: dish.id ?? '',
                                            name: dish.name,
                                            price: dish.price,
                                            imageUrl: dish.imageUrl,
                                            restaurantId: id,
                                            description: dish.description ?? '',
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DishDetailPage(
                                                    id: dish.id ?? '',
                                                    restaurantId: id,
                                                    name: dish.name,
                                                    price: dish.price,
                                                    imageUrl: dish.imageUrl,
                                                    rating: '0.0',
                                                    description:
                                                        dish.description ?? '',
                                                  ),
                                                ),
                                              );
                                              // Forcer le rafraîchissement après le retour
                                              ref
                                                  .read(refreshKey.notifier)
                                                  .state++;
                                            },
                                          );
                                        },
                                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          // Bouton flottant de commande moderne
          FloatingOrderButton(
            restaurantName: name,
          ),
        ],
      ),
    );
  }
}
