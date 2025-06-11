import 'package:flutter/material.dart';
import '../../../../../../core/ui/theme/theme.dart';

class DishCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DishCard({
    Key? key,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: quantity > 0
                      ? UIColors.orange.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      quantity > 0 ? '$quantity.X' : '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: UIColors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (quantity > 0 && onDelete != null) ...[
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
              CircleAvatar(
                backgroundColor: UIColors.orange,
                radius: 12,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, color: Colors.white, size: 10),
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
