class DishModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final double rating;
  final String categorie;
  final String preparationTime;
  final int sodas;

  DishModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.categorie,
    required this.preparationTime,
    required this.sodas,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'].toString(),
      restaurantId: json['restaurant_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: int.tryParse(json['price'].toString()) ?? 0,
      imageUrl: json['image_url'] ?? '',
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      categorie: json['categorie'] ?? '',
      preparationTime: json['preparation_time'] ?? '',
      sodas: int.tryParse(json['sodas'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'rating': rating,
      'categorie': categorie,
      'preparation_time': preparationTime,
      'sodas': sodas,
    };
  }
}
