import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/core/ui/theme/theme.dart';
import '../providers/modern_order_provider.dart';

class ModernDishCard extends ConsumerWidget {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String restaurantId;
  final String description;
  final VoidCallback? onTap;

  const ModernDishCard({
    Key? key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.description,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(itemQuantityProvider(id));

    return Container(
      width: 100,
      height: 200,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du plat - hauteur fixe
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fastfood,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenu de la carte - hauteur fixe
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du plat
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Description
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Prix et boutons de quantité
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Prix
                          Expanded(
                            child: Text(
                              '$price FCFA',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: UIColors.orange,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 4),

                          // Boutons de quantité
                          _QuantityControls(
                            quantity: quantity,
                            onAdd: () => _addItem(ref),
                            onRemove: () => _removeItem(ref),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addItem(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).addItem(
          id: id,
          name: name,
          price: price,
          imageUrl: imageUrl,
          restaurantId: restaurantId,
          description: description,
        );
  }

  void _removeItem(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).removeItem(id);
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityControls({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      // Bouton d'ajout initial
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: UIColors.orange,
          borderRadius: BorderRadius.circular(14),
        ),
        child: IconButton(
          onPressed: onAdd,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 16,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
        ),
      );
    }

    // Contrôles de quantité
    return Container(
      decoration: BoxDecoration(
        color: UIColors.orange,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      height: 28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton moins
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),

          // Quantité
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bouton plus
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Version simple pour les listes
class ModernDishCardSimple extends ConsumerWidget {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String restaurantId;
  final String description;
  final bool sodas;
  final VoidCallback? onTap;

  const ModernDishCardSimple({
    Key? key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.description,
    required this.sodas,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(itemQuantityProvider(id));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image du plat
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.grey,
                    ),
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
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$price FCFA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: UIColors.orange,
                          ),
                        ),
                        _QuantityControls(
                          quantity: quantity,
                          onAdd: () => _addItem(ref),
                          onRemove: () => _removeItem(ref),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addItem(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).addItem(
          id: id,
          name: name,
          price: price,
          imageUrl: imageUrl,
          restaurantId: restaurantId,
          description: description,
        );
  }

  void _removeItem(WidgetRef ref) {
    ref.read(modernOrderProvider.notifier).removeItem(id);
  }
}
