class LikedDish {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final double rating;
  final String userId;
  final DateTime likedAt;

  const LikedDish({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.userId,
    required this.likedAt,
  });

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

  factory LikedDish.fromJson(Map<String, dynamic> json) {
    return LikedDish(
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
}
