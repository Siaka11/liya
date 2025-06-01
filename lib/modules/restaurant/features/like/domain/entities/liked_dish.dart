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
  final bool sodas;

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
    required this.sodas,
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
      'sodas': sodas,
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
      sodas: json['sodas'] == true ||
          json['sodas'] == 1 ||
          json['sodas'] == '1' ||
          json['sodas'] == 'true',
      likedAt: DateTime.parse(json['likedAt'] as String),
    );
  }
}
