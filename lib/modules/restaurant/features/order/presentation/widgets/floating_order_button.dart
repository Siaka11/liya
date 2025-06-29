import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import '../providers/modern_order_provider.dart';
// Import pour la navigation AutoRoute
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';

class FloatingOrderButton extends ConsumerWidget {
  final VoidCallback? onTap;
  final String? restaurantName;

  const FloatingOrderButton({
    Key? key,
    this.onTap,
    this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(modernOrderProvider);
    final totalItems = ref.watch(orderTotalItemsProvider);
    final totalPrice = ref.watch(orderTotalPriceProvider);
    final isLoading = orderState.isLoading;

    // Ne pas afficher le bouton si la commande est vide
    if (orderState.isEmpty) {
      return const SizedBox.shrink();
    }

    // Utiliser le restaurantName de la commande si disponible, sinon utiliser celui passé en paramètre
    final displayRestaurantName = restaurantName ??
        (orderState.restaurantId != null
            ? ref.watch(restaurantNameProvider(orderState.restaurantId!))
            : null) ??
        'Restaurant';

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLoading
                ? null
                : (onTap ?? () => _showOrderDetails(context, ref)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Badge avec le nombre d'articles
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: UIColors.orange,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      '$totalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Informations de la commande
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Voir votre commande',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayRestaurantName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Prix total et bouton de commande
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${totalPrice.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: UIColors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: UIColors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Commander',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsSheet(context: context),
    );
  }
}

class OrderDetailsSheet extends ConsumerWidget {
  final BuildContext context;

  const OrderDetailsSheet({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(modernOrderProvider);
    final totalPrice = ref.watch(orderTotalPriceProvider);
    final isLoading = orderState.isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Votre commande',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${orderState.totalItems} article${orderState.totalItems > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Liste des articles
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: orderState.itemsList.length,
              itemBuilder: (context, index) {
                final item = orderState.itemsList[index];
                return _OrderItemTile(item: item);
              },
            ),
          ),

          // Séparateur
          const Divider(height: 1),

          // Total et bouton de commande
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: UIColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : () => _placeOrder(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Passer la commande',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder(BuildContext context, WidgetRef ref) async {
    final orderState = ref.read(modernOrderProvider);

    // Vérifier qu'il y a des articles
    if (orderState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre commande est vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fermer le modal
    Navigator.pop(context);

    // Rediriger vers le checkout avec les données de la commande
    try {
      // Convertir les articles en format compatible avec CheckoutRoute
      final cartItems = orderState.itemsList
          .map((item) => {
                'name': item.name,
                'price': item.price,
                'description': item.description,
                'quantity': item.quantity,
              })
          .toList();

      // Navigation vers CheckoutRoute avec AutoRoute
      context.router.push(
        CheckoutRoute(
          restaurantName: orderState.restaurantId ?? '',
          cartItems: cartItems,
        ),
      );
    } catch (e) {
      // Si la navigation échoue, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la navigation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _OrderItemTile extends ConsumerWidget {
  final OrderItemState item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Image du plat
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Informations du plat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price} FCFA',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Contrôles de quantité
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(modernOrderProvider.notifier).removeItem(item.id),
                icon: const Icon(Icons.remove_circle_outline),
                color: UIColors.orange,
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => ref.read(modernOrderProvider.notifier).addItem(
                      id: item.id,
                      name: item.name,
                      price: item.price,
                      imageUrl: item.imageUrl,
                      restaurantId: item.restaurantId,
                      description: item.description,
                    ),
                icon: const Icon(Icons.add_circle_outline),
                color: UIColors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
