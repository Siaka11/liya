import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/core/local_storage_factory.dart';
import 'package:liya/core/singletons.dart';
import '../../application/dish_provider.dart';
import '../../../order/presentation/widgets/modern_dish_card.dart';
import '../../../order/presentation/widgets/floating_order_button.dart';
import 'dish_detail_page.dart';

@RoutePage(name: 'ModernRestaurantDetailRoute')
class ModernRestaurantDetailPage extends ConsumerWidget {
  final String id;
  final String name;
  final String description;
  final String coverImage;

  const ModernRestaurantDetailPage({
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (dishState.dishes == null && !dishState.isLoading) {
        dishController.loadDishes(id);
      }
    });

    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      body: Stack(
        children: [
          // Image de couverture
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

          // Contenu principal
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 300),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informations du restaurant
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_shipping,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Livraison 25-35 min',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),

                        // Titre de la section plats
                        const Text(
                          'Nos plats',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Liste des plats
                        _buildDishesList(dishState),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bouton de retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Bouton flottant de commande
          FloatingOrderButton(
            restaurantName: name,
          ),
        ],
      ),
    );
  }

  Widget _buildDishesList(dishState) {
    if (dishState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dishState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur: ${dishState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (dishState.dishes == null || dishState.dishes!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const Icon(Icons.restaurant, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                "Aucun plat disponible pour ce restaurant",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          onTap: () {
            Navigator.push(
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
  }
}
