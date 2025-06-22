import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';

class DishCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final String description;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final int quantity;

  const DishCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.onTap,
    this.onDelete,
    this.quantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4, top: 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du plat
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 100),
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
                        fontSize: 14,
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
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Prix et quantité sur la même ligne
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$price CFA',
                          style: const TextStyle(
                            fontSize: 16,
                            color: UIColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Indicateur de quantité
                        if (quantity > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: UIColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: UIColors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (onDelete != null) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: onDelete,
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
}
