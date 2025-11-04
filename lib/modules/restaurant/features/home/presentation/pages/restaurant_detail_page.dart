import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/home/data/datasources/dish_firestore_data_source.dart';
import 'package:liya/modules/restaurant/features/home/data/models/dish_model.dart';
import 'package:liya/modules/restaurant/features/home/presentation/pages/dish_detail_page.dart';

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
    // Créer une instance de DishFirestoreDataSource
    final dishDataSource = DishFirestoreDataSource();

    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      body: Stack(
        children: [
          // Image de fond avec overlay
          Container(
            height: 300,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: Image.network(
                      coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant,
                            size: 100, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            const Text('Livraison 25-35 min',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(description,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        const Text('Plats disponibles',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),

                        // Grille des plats avec scroll fluide
                        FutureBuilder<List<DishModel>>(
                          future: dishDataSource.getDishesByRestaurant(id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Erreur: ${snapshot.error}'),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                    'Aucun plat disponible pour ce restaurant'),
                              );
                            }

                            final dishes = snapshot.data!;

                            return GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const ClampingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: dishes.length,
                              itemBuilder: (context, index) {
                                final dish = dishes[index];
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
                                        builder: (context) => DishDetailPage(
                                          id: dish.id ?? '',
                                          restaurantId: id,
                                          name: dish.name,
                                          price: dish.price,
                                          imageUrl: dish.imageUrl,
                                          rating: '0.0',
                                          description: dish.description ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),

                        // Espace en bas pour le bouton flottant
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bouton de fermeture
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.7),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Bouton flottant
          FloatingOrderButton(restaurantName: name),
        ],
      ),
    );
  }
}
