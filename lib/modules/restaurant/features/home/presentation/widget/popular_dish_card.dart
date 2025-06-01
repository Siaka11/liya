import 'package:flutter/material.dart';
import '../pages/dish_detail_page.dart';
import 'package:liya/modules/restaurant/features/like/presentation/widgets/like_button.dart';

class PopularDishCard extends StatelessWidget {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String restaurantId;
  final String description;
  final String userId;
  final bool sodas;
  final VoidCallback onAddToCart;

  const PopularDishCard({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.description,
    required this.userId,
    required this.onAddToCart,
    required this.sodas,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DishDetailPage(
              id: id,
              restaurantId: restaurantId,
              name: name,
              price: price,
              imageUrl: imageUrl,
              rating: '0.0',
              description: description,
              sodas: sodas,
            ),
          ),
        );
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey,
        child: Container(
          width: 240,
          height: 180,
          child: Stack(
            children: [
              // Image en arrière-plan
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 240,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    size: 200,
                  ),
                ),
              ),
              // Prix en haut à gauche dans un cercle
              Positioned(
                top: 8,
                left: 6,
                child: Container(
                  padding: EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.6),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    price + ' F',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Bouton Like en haut à droite
              Positioned(
                top: 8,
                right: 4,
                child: LikeButton(
                  dishId: id,
                  userId: userId,
                  name: name,
                  price: price,
                  imageUrl: imageUrl,
                  description: description,
                  sodas: sodas,
                ),
              ),
              // Cadre contenant le nom et le bouton "Ajouter au panier"
              Positioned(
                bottom: 4,
                left: 2,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Nom en bas à gauche
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Bouton "Ajouter au panier" en bas à droite
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: GestureDetector(
                          onTap: onAddToCart,
                          child: Text(
                            "Ajouter au panier",
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
}
