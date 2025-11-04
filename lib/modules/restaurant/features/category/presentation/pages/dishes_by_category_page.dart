import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/home/application/categories_firebase_provider.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';
import 'package:liya/core/ui/theme/theme.dart';

class DishesByCategoryPage extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const DishesByCategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesState = ref.watch(dishesByCategoryProvider(categoryId));
    final dishesController =
        ref.read(dishesByCategoryProvider(categoryId).notifier);

    // Charger les plats de cette catégorie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishesState.categories == null && !dishesState.isLoading) {
        dishesController.loadDishesByCategory(categoryId, categoryName);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                dishesController.loadDishesByCategory(categoryId, categoryName),
          ),
        ],
      ),
      body: dishesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dishesState.error != null
              ? Center(child: Text('Erreur: ${dishesState.error}'))
              : dishesState.categories == null ||
                      dishesState.categories!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun plat disponible\ndans cette catégorie',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: dishesState.categories!.length,
                      itemBuilder: (context, index) {
                        final dish = dishesState.categories![index];
                        return ModernDishCard(
                          id: dish['id'],
                          name: dish['name'],
                          price: dish['price'].toString(),
                          imageUrl: dish['image_url'],
                          restaurantId: dish['restaurant_id'],
                          description: dish['description'],
                          isOnSale: dish['is_on_sale'] ?? false,
                          originalPrice:
                              (dish['original_price'] ?? dish['price'])
                                  .toDouble(),
                          discountPercentage:
                              dish['discount_percentage'] ?? 0.0,
                          orderCount: dish['order_count'] ?? 0,
                          rating: (dish['rating'] ?? 0.0).toDouble(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DishDetailPage(
                                  id: dish['id'],
                                  restaurantId: dish['restaurant_id'],
                                  name: dish['name'],
                                  price: dish['price'].toString(),
                                  imageUrl: dish['image_url'],
                                  rating: dish['rating'].toString(),
                                  description: dish['description'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
