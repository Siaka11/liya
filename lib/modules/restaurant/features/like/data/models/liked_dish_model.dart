import '../../domain/entities/liked_dish.dart';

class LikedDishModel extends LikedDish {
  LikedDishModel({
    required String id,
    required String restaurantId,
    required String name,
    required double price,
    required String imageUrl,
    required String description,
    required double rating,
    required String userId,
    required DateTime likedAt,
  }) : super(
          id: id,
          restaurantId: restaurantId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          description: description,
          rating: rating,
          userId: userId,
          likedAt: likedAt,
        );

  factory LikedDishModel.fromJson(Map<String, dynamic> json) {
    return LikedDishModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      userId: json['userId'] as String,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'userId': userId,
      'likedAt': likedAt.toIso8601String(),
    };
  }
}
