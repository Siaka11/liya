import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/modern_order_provider.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';

/// Page de test simple pour vérifier le système moderne
class TestModernSystemPage extends ConsumerWidget {
  const TestModernSystemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(modernOrderProvider);
    final totalItems = ref.watch(orderTotalItemsProvider);
    final totalPrice = ref.watch(orderTotalPriceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Système Moderne'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations sur l'état
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'État de la commande :',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Articles: $totalItems'),
                      Text('Prix total: ${totalPrice.toStringAsFixed(0)} FCFA'),
                      Text('Restaurant: ${orderState.restaurantId ?? 'Aucun'}'),
                      Text('Vide: ${orderState.isEmpty}'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Boutons de test
                const Text(
                  'Actions de test :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () => _addTestItem(ref, 'Pizza Test', '2500'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter Pizza Test'),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () => _addTestItem(ref, 'Burger Test', '1800'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter Burger Test'),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () =>
                      ref.read(modernOrderProvider.notifier).clearOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Vider la commande'),
                ),

                const SizedBox(height: 24),

                // Exemples de cartes de plats
                const Text(
                  'Exemples de cartes :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Carte de plat 1
                ModernDishCard(
                  id: 'test_dish_1',
                  name: 'Pizza Margherita',
                  price: '2500',
                  imageUrl:
                      'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400',
                  restaurantId: 'test_restaurant',
                  description:
                      'Pizza traditionnelle avec mozzarella et basilic',
                  sodas: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pizza Margherita sélectionnée')),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Carte de plat 2
                ModernDishCard(
                  id: 'test_dish_2',
                  name: 'Burger Classic',
                  price: '1800',
                  imageUrl:
                      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
                  restaurantId: 'test_restaurant',
                  description: 'Burger avec steak, salade, tomate et fromage',
                  sodas: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Burger Classic sélectionné')),
                    );
                  },
                ),

                const SizedBox(height: 100), // Espace pour le bouton flottant
              ],
            ),
          ),

          // Bouton flottant de commande
          const FloatingOrderButton(),
        ],
      ),
    );
  }

  void _addTestItem(WidgetRef ref, String name, String price) {
    ref.read(modernOrderProvider.notifier).addItem(
          id: 'test_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: price,
          imageUrl: 'https://via.placeholder.com/150',
          restaurantId: 'test_restaurant',
          description: 'Article de test',
          sodas: false,
        );
  }
}
