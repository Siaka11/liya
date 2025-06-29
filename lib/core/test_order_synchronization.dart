import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/modern_order_provider.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';

/// Page de test pour vérifier la synchronisation des commandes
class TestOrderSynchronizationPage extends ConsumerWidget {
  const TestOrderSynchronizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(modernOrderProvider);
    final totalItems = ref.watch(orderTotalItemsProvider);
    final totalPrice = ref.watch(orderTotalPriceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Synchronisation Commandes'),
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
                // État actuel de la commande
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
                      Text(
                          'Restaurant ID: ${orderState.restaurantId ?? 'Aucun'}'),
                      Text('Vide: ${orderState.isEmpty}'),
                      Text(
                          'Même restaurant: ${orderState.isFromSameRestaurant}'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tests de synchronisation
                const Text(
                  'Tests de synchronisation :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Test 1: Ajouter des plats du même restaurant (format numérique)
                ElevatedButton(
                  onPressed: () =>
                      _addTestItem(ref, 'Pizza Test 1', '2500', '1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter Pizza (Restaurant 1)'),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () =>
                      _addTestItem(ref, 'Burger Test 1', '1800', '1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter Burger (Restaurant 1)'),
                ),

                const SizedBox(height: 16),

                // Test 2: Ajouter des plats d'un restaurant différent (format string)
                ElevatedButton(
                  onPressed: () =>
                      _addTestItem(ref, 'Sushi Test 2', '3000', 'restaurant_2'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                      'Ajouter Sushi (Restaurant 2) - Devrait vider la commande'),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () => _addTestItem(
                      ref, 'Salade Test 2', '1200', 'restaurant_2'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter Salade (Restaurant 2)'),
                ),

                const SizedBox(height: 16),

                // Test 3: Ajouter des plats avec des formats mixtes
                ElevatedButton(
                  onPressed: () =>
                      _addTestItem(ref, 'Pasta Test 3', '2000', '3'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                      'Ajouter Pasta (Restaurant 3) - Devrait vider la commande'),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: () =>
                      _addTestItem(ref, 'Dessert Test 3', '800', '3'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter Dessert (Restaurant 3)'),
                ),

                const SizedBox(height: 16),

                // Boutons de contrôle
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            ref.read(modernOrderProvider.notifier).clearOrder(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Vider la commande'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showOrderDetails(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Voir détails'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Liste des articles
                if (orderState.isNotEmpty) ...[
                  const Text(
                    'Articles dans la commande :',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...orderState.itemsList.map((item) => Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle:
                              Text('${item.price} FCFA x ${item.quantity}'),
                          trailing: Text(
                              '${item.totalPrice.toStringAsFixed(0)} FCFA'),
                        ),
                      )),
                ],

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

  void _addTestItem(
      WidgetRef ref, String name, String price, String restaurantId) {
    ref.read(modernOrderProvider.notifier).addItem(
          id: 'test_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: price,
          imageUrl: 'https://via.placeholder.com/150',
          restaurantId: restaurantId,
          description: 'Article de test pour la synchronisation',
          sodas: false,
        );
  }

  void _showOrderDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la commande'),
        content: Consumer(
          builder: (context, ref, child) {
            final orderState = ref.watch(modernOrderProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Restaurant ID: ${orderState.restaurantId ?? 'Aucun'}'),
                Text('Articles: ${orderState.totalItems}'),
                Text(
                    'Prix total: ${orderState.totalPrice.toStringAsFixed(0)} FCFA'),
                Text('Même restaurant: ${orderState.isFromSameRestaurant}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
