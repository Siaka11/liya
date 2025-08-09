import 'package:flutter/material.dart';

class RestaurantFirebaseCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onTap;
  final double width;

  const RestaurantFirebaseCard({
    required this.restaurant,
    required this.onTap,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0.05,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: width,
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    restaurant['cover_image'] ?? '',
                    width: width,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: width,
                      height: 130,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                // Contenu (nom et informations)
                const SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant['name'] ?? 'Restaurant inconnu',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              Text(
                                ' ${(restaurant['rating'] ?? 0.0).toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant['average_delivery_time'] ?? 30} min",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.restaurant_menu,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant['dishes_count'] ?? 0} plats",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
        ));
  }
}
