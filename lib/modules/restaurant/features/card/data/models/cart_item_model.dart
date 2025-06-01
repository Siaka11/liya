import 'package:liya/modules/restaurant/features/card/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required String id,
    required String name,
    required String price,
    required String imageUrl,
    required String restaurantId,
    required String description,
    required String rating,
    required int quantity,
    required String user,
    required bool sodas,
  }) : super(
          id: id,
          name: name,
          price: price,
          imageUrl: imageUrl,
          restaurantId: restaurantId,
          description: description,
          rating: rating,
          quantity: quantity,
          user: user,
          sodas: sodas,
        );

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "imageUrl": imageUrl,
      "restaurantId": restaurantId,
      "description": description,
      "rating": rating,
      "quantity": quantity,
      "user": user,
      "sodas": sodas,
    };
  }

  factory CartItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItemModel(
      id: id,
      name: data["name"] ?? '',
      price: data["price"] ?? '',
      imageUrl: data["imageUrl"] ?? '',
      restaurantId: data["restaurantId"] ?? '',
      description: data["description"] ?? '',
      rating: data["rating"] ?? '0.0',
      quantity: data["quantity"] ?? 1,
      user: data["user"] ?? '',
      sodas: data["sodas"] == true ||
          data["sodas"] == 1 ||
          data["sodas"] == '1' ||
          data["sodas"] == 'true',
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json["id"],
      name: json["name"],
      price: json["price"],
      imageUrl: json["imageUrl"],
      restaurantId: json["restaurantId"],
      description: json["description"],
      rating: json["rating"],
      quantity: json["quantity"],
      user: json["user"],
      sodas: json["sodas"] == true ||
          json["sodas"] == 1 ||
          json["sodas"] == '1' ||
          json["sodas"] == 'true',
    );
  }
}
