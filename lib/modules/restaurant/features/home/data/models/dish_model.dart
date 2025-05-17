import '../../domain/entities/dish.dart';



class DishModel extends Dish {
  DishModel({
    required String id,
    required String name,
    required String price,
    required String imageUrl,
    required String restaurantId,
    required String description,
  }) : super(id: id, name: name, price: price, imageUrl: imageUrl, restaurantId: restaurantId, description: description);

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'].toString(),
      name: json['name'],
      price: json['price'].toString(),
      imageUrl: json['image_url'],
      restaurantId: json['restaurant_id'].toString(),
      description: json['description'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'restaurant_id': restaurantId,
      'description': description,
    };
  }
}