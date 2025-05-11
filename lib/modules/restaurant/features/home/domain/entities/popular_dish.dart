import 'package:equatable/equatable.dart';

class PopularDish extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String price;
 final String imageUrl;
 final String rating;
  /*  final String categorie;
  final String preparationTime;*/

  const PopularDish({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
/*     required this.categorie,
    required this.preparationTime,*/
  });

  @override
  List<Object?> get props => [id, restaurantId, name, price, description];

  // Méthode pour créer un PopularDish à partir d'un JSON
  factory PopularDish.fromJson(Map<String, dynamic> json) {
    return PopularDish(
      id: json['id'] as String? ?? '',
      restaurantId: json['restaurantId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Dish',
      description: json['description'],
      price: json['price'] as String? ?? '0.00 F',
      imageUrl: json['image_url'],
     rating: (json['rating'] ),
/*        categorie: (json['categorie'] ),
      preparationTime: (json['preparationTime'] ),*/
    );
  }

  // Méthode pour convertir un PopularDish en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
       'rating': rating,
/*      'categorie': categorie,
      'preparationTime': preparationTime,*/
    };
  }
}