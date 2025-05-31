import 'package:liya/modules/restaurant/features/like/domain/entities/liked_dish.dart';

class LikedDishModel extends LikedDish {
  const LikedDishModel({
    required super.id,
    required super.dishId,
    required super.userId,
    required super.name,
    required super.price,
    required super.imageUrl,
    required super.description,
    required super.likedAt,
  });

  factory LikedDishModel.fromJson(Map<String, dynamic> json) {
    return LikedDishModel(
      id: json['id'] as String,
      dishId: json['dishId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      price: json['price'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dishId': dishId,
      'userId': userId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'likedAt': likedAt.toIso8601String(),
    };
  }
}
