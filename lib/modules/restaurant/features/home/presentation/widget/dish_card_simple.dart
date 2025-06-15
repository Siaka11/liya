import 'package:flutter/material.dart';
import 'package:liya/modules/restaurant/features/like/presentation/widgets/like_button.dart';
import '../../domain/entities/dish.dart';
import '../../presentation/pages/dish_detail_page.dart';

class DishCardSimple extends StatelessWidget {
  final Dish dish;
  final String userId;

  const DishCardSimple({
    Key? key,
    required this.dish,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DishDetailPage(
              id: dish.id,
              restaurantId: dish.restaurantId,
              name: dish.name,
              price: dish.price,
              imageUrl: dish.imageUrl,
              rating: '0.0',
              description: dish.description,
              sodas: dish.sodas,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        color: const Color(0xFFF7F7F7),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  dish.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error, size: 60),
                ),
              ),
              const SizedBox(width: 16),
              // Infos plat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dish.price} F',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton like
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: LikeButton(
                  dishId: dish.id,
                  userId: userId,
                  name: dish.name,
                  price: dish.price,
                  imageUrl: dish.imageUrl,
                  description: dish.description,
                  sodas: dish.sodas,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
