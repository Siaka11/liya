import '../../domain/entities/dish.dart';

class DishModel extends Dish {
  DishModel({
    required String id,
    required String name,
    required String description,
    required String price,
    required String imageUrl,
    required String categoryId,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          categoryId: categoryId,
        );

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toString(),
      imageUrl: json['image_url'] ?? '',
      categoryId: json['categoryId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
    };
  }
}
