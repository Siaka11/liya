import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import 'package:liya/modules/restaurant/features/order/presentation/providers/modern_order_provider.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/floating_order_button.dart';
import 'package:liya/modules/restaurant/features/order/presentation/widgets/modern_dish_card.dart';

/// Exemple de démonstration du nouveau système de commande moderne
class ModernOrderExample extends ConsumerWidget {
  const ModernOrderExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: UIColors.defaultColor,
      appBar: AppBar(
        title: const Text('Démonstration - Système Moderne'),
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
                // En-tête
                const Text(
                  'Nouveau Système de Commande',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Approche moderne comme Glovo - Bouton flottant avec état global',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Section d'exemples de plats
                const Text(
                  'Exemples de plats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Grille de plats d'exemple
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _exampleDishes.length,
                  itemBuilder: (context, index) {
                    final dish = _exampleDishes[index];
                    return ModernDishCard(
                      id: dish['id']!,
                      name: dish['name']!,
                      price: dish['price']!,
                      imageUrl: dish['imageUrl']!,
                      restaurantId: dish['restaurantId']!,
                      description: dish['description']!,
                      sodas: dish['sodas']!,
                      onTap: () {
                        _showDishDetails(context, dish);
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Informations sur le système
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
                        'Fonctionnalités du nouveau système :',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('✅ État global avec Riverpod'),
                      _buildFeatureItem('✅ Bouton flottant intelligent'),
                      _buildFeatureItem('✅ Contrôles +/- sur chaque plat'),
                      _buildFeatureItem('✅ Même restaurant uniquement'),
                      _buildFeatureItem('✅ Mise à jour en temps réel'),
                      _buildFeatureItem('✅ Interface moderne comme Glovo'),
                    ],
                  ),
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _showDishDetails(BuildContext context, Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dish['name']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prix: ${dish['price']!} FCFA'),
            const SizedBox(height: 8),
            Text('Description: ${dish['description']!}'),
            const SizedBox(height: 16),
            const Text(
              'Utilisez les boutons +/- pour ajouter/retirer ce plat de votre commande.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
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

// Données d'exemple pour la démonstration
final List<Map<String, dynamic>> _exampleDishes = [
  {
    'id': 'dish_1',
    'name': 'Pizza Margherita',
    'price': '2500',
    'imageUrl':
        'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400',
    'restaurantId': 'restaurant_1',
    'description': 'Pizza traditionnelle avec mozzarella et basilic',
    'sodas': true,
  },
  {
    'id': 'dish_2',
    'name': 'Burger Classic',
    'price': '1800',
    'imageUrl':
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    'restaurantId': 'restaurant_1',
    'description': 'Burger avec steak, salade, tomate et fromage',
    'sodas': true,
  },
  {
    'id': 'dish_3',
    'name': 'Salade César',
    'price': '1200',
    'imageUrl':
        'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
    'restaurantId': 'restaurant_1',
    'description': 'Salade fraîche avec poulet grillé et parmesan',
    'sodas': false,
  },
  {
    'id': 'dish_4',
    'name': 'Pâtes Carbonara',
    'price': '1600',
    'imageUrl':
        'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
    'restaurantId': 'restaurant_1',
    'description': 'Pâtes crémeuses avec lardons et parmesan',
    'sodas': true,
  },
  {
    'id': 'dish_5',
    'name': 'Sushi California',
    'price': '2200',
    'imageUrl':
        'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
    'restaurantId': 'restaurant_1',
    'description': 'Rouleaux de sushi avec avocat et crabe',
    'sodas': true,
  },
  {
    'id': 'dish_6',
    'name': 'Tiramisu',
    'price': '800',
    'imageUrl':
        'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
    'restaurantId': 'restaurant_1',
    'description': 'Dessert italien avec mascarpone et café',
    'sodas': false,
  },
];

/// Widget pour tester le système de commande
class ModernOrderTester extends ConsumerWidget {
  const ModernOrderTester({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(modernOrderProvider);
    final totalItems = ref.watch(orderTotalItemsProvider);
    final totalPrice = ref.watch(orderTotalPriceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test du Système Moderne'),
        backgroundColor: UIColors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // État actuel
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

            const SizedBox(height: 20),

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
              onPressed: () => _addTestItem(ref, 'Test 1'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajouter Test 1'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _addTestItem(ref, 'Test 2'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ajouter Test 2'),
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
              Expanded(
                child: ListView.builder(
                  itemCount: orderState.itemsList.length,
                  itemBuilder: (context, index) {
                    final item = orderState.itemsList[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.price} FCFA x ${item.quantity}'),
                        trailing:
                            Text('${item.totalPrice.toStringAsFixed(0)} FCFA'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addTestItem(WidgetRef ref, String name) {
    ref.read(modernOrderProvider.notifier).addItem(
          id: 'test_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          price: '1000',
          imageUrl: 'https://via.placeholder.com/150',
          restaurantId: 'test_restaurant',
          description: 'Article de test',
          sodas: false,
        );
  }
}
