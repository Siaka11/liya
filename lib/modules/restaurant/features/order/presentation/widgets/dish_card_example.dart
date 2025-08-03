import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'modern_dish_card.dart';
import 'parallax_dish_list.dart';

class DishCardExample extends ConsumerWidget {
  const DishCardExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Exemple de données de plats
    final sampleDishes = [
      DishItem(
        id: '1',
        name: 'Poulet Braisé',
        price: '2500',
        imageUrl:
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
        restaurantId: 'rest1',
        description: 'Poulet braisé avec accompagnements traditionnels',
      ),
      DishItem(
        id: '2',
        name: 'Attieke Poisson',
        price: '1800',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
        restaurantId: 'rest1',
        description: 'Attieke avec poisson grillé et légumes',
      ),
      DishItem(
        id: '3',
        name: 'Kedjenou',
        price: '2200',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
        restaurantId: 'rest1',
        description: 'Poulet cuit à l\'étouffée avec épices',
      ),
      DishItem(
        id: '4',
        name: 'Alloco',
        price: '1200',
        imageUrl:
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
        restaurantId: 'rest1',
        description: 'Bananes plantains frites avec sauce piment',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Dish Cards Animés'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Section avec ModernDishCard
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ModernDishCard avec Animation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sampleDishes.length,
                    itemBuilder: (context, index) {
                      final dish = sampleDishes[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: ModernDishCard(
                          id: dish.id,
                          name: dish.name,
                          price: dish.price,
                          imageUrl: dish.imageUrl,
                          restaurantId: dish.restaurantId,
                          description: dish.description,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sélectionné: ${dish.name}'),
                                backgroundColor: UIColors.orange,
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
          ),

          const Divider(height: 1),

          // Section avec ParallaxDishList
          Expanded(
            child: ParallaxDishList(
              dishes: sampleDishes,
              title: 'Plats du Jour',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Liste de plats avec effet parallaxe'),
                    backgroundColor: UIColors.orange,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de démonstration pour tester les animations
class DishCardDemo extends ConsumerWidget {
  const DishCardDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démo Animations'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionCard(
              '1. ModernDishCard',
              'Tapez sur une carte pour voir l\'animation de scale et slide. Le bouton de quantité reste fixe.',
              Icons.touch_app,
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              '2. ParallaxDishList',
              'Scroll vers le haut pour voir l\'effet parallaxe. L\'image se redimensionne et le contenu glisse.',
              Icons.swipe_up,
            ),
            const SizedBox(height: 12),
            _buildInstructionCard(
              '3. Boutons Animés',
              'Les boutons de quantité ont des animations de pression et de rebond.',
              Icons.animation,
            ),
            const SizedBox(height: 24),

            // Grille de démonstration
            const Text(
              'Grille de Démonstration:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final dish = [
                  {
                    'name': 'Poulet Braisé',
                    'price': '2500',
                    'image':
                        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
                    'description': 'Poulet braisé traditionnel',
                  },
                  {
                    'name': 'Attieke Poisson',
                    'price': '1800',
                    'image':
                        'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
                    'description': 'Attieke avec poisson',
                  },
                  {
                    'name': 'Kedjenou',
                    'price': '2200',
                    'image':
                        'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
                    'description': 'Poulet à l\'étouffée',
                  },
                  {
                    'name': 'Alloco',
                    'price': '1200',
                    'image':
                        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',
                    'description': 'Bananes plantains frites',
                  },
                ][index];

                return ModernDishCard(
                  id: 'demo_$index',
                  name: dish['name']!,
                  price: dish['price']!,
                  imageUrl: dish['image']!,
                  restaurantId: 'demo_rest',
                  description: dish['description']!,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sélectionné: ${dish['name']}'),
                        backgroundColor: UIColors.orange,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard(
      String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UIColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: UIColors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
