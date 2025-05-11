

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';

@RoutePage(name: 'DishDetailRoute')
class DishDetailPage extends StatefulWidget {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final String rating;

  const DishDetailPage({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.rating,
    required this.id,
    required this.description,
  });

  @override
  _DishDetailPageState createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  int quantity = 1;

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Convertir le prix en double pour le calcul
    double basePrice = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double totalPrice = basePrice * quantity;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec superposition des éléments
          Container(
            height: MediaQuery.of(context).size.height * 0.5, // Hauteur de l'image
            width: double.infinity,
            child: Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20), // Coins arrondis en bas
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.5,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.error,
                      size: 300,
                    ),
                  ),
                ),
                // Bouton retour
                Positioned(
                  top: 50,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Icône de cœur en haut à droite
                Positioned(
                  top: 60,
                  right: 16,
                  child: Icon(Icons.favorite_border, color: Colors.orange, size: 24),
                ),
              ],
            ),
          ),
          // Cadre blanc avec les détails (contenu défilable)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20), // Coins arrondis en haut
                ),
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du plat
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Note avec étoile
                    Row(
                      children: [
                        Text('${widget.price} CFA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Icon(Icons.star, size: 20, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          widget.rating,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Description
                    Text(
                      "Offrez-vous un réveil tout en douceur avec notre petit-déjeuner à la française. Imaginez : des arômes de café fraîchement moulu,",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Compteur et bouton "Ajouter au panier" fixés en bas
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white, // Pour correspondre au cadre blanc
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Compteur
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Couleur par défaut pour le compteur
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.black),
                            onPressed: decrementQuantity,
                          ),
                          Text(
                            quantity.toString().padLeft(2, '0'), // Quantité formatée (ex: "01")
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.black),
                            onPressed: incrementQuantity,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                // Bouton "Ajouter au panier" dynamique
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      print("Ajouté au panier : ${widget.name} (Restaurant: ${widget.restaurantId}) - Quantité: $quantity, Total: ${totalPrice.toStringAsFixed(2)} CFA");
                    },
                    child: Text(
                      "Ajouter $quantity pour ${totalPrice.toStringAsFixed(3)} CFA",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}