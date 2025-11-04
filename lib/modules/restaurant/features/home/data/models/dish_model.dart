import '../../domain/entities/dish.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DishModel extends Dish {
  DishModel({
    required String id,
    required String name,
    required String price,
    required String imageUrl,
    required String restaurantId,
    required String description,
    String category = '',
    String preparationTime = '',
    bool isAvailable = true,
    double rating = 0.0,
    int ratingCount = 0,
    int orderCount = 0,
    int viewCount = 0,
    double popularityScore = 0.0,
    DateTime? lastOrdered,
    DateTime? lastViewed,
    DateTime? createdAt,
    DateTime? updatedAt,
    int sodas = 0,
    List<String> supplements = const [],
    List<String> allergens = const [],
    Map<String, dynamic> nutritionalInfo = const {},
    List<String> tags = const [],
    bool isVegetarian = false,
    bool isVegan = false,
    bool isGlutenFree = false,
    bool isSpicy = false,
    int calories = 0,
    double protein = 0.0,
    double carbs = 0.0,
    double fat = 0.0,
  }) : super(
            id: id,
            name: name,
            price: price,
            imageUrl: imageUrl,
            restaurantId: restaurantId,
            description: description,
            category: category,
            preparationTime: preparationTime,
            isAvailable: isAvailable,
            rating: rating,
            ratingCount: ratingCount,
            orderCount: orderCount,
            viewCount: viewCount,
            popularityScore: popularityScore,
            lastOrdered: lastOrdered,
            lastViewed: lastViewed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            sodas: sodas,
            supplements: supplements,
            allergens: allergens,
            nutritionalInfo: nutritionalInfo,
            tags: tags,
            isVegetarian: isVegetarian,
            isVegan: isVegan,
            isGlutenFree: isGlutenFree,
            isSpicy: isSpicy,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat);

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: json['price'].toString(),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      restaurantId:
          json['restaurant_id']?.toString() ?? json['restaurantId'] ?? '',
      description: json['description']?.toString() ?? '',
      category: json['categorie'] ?? json['category'] ?? '',
      preparationTime:
          json['preparation_time'] ?? json['preparationTime'] ?? '',
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] ?? json['ratingCount'] ?? 0,
      orderCount: json['order_count'] ?? json['orderCount'] ?? 0,
      viewCount: json['view_count'] ?? json['viewCount'] ?? 0,
      popularityScore: (json['popularity_score'] as num?)?.toDouble() ?? 0.0,
      lastOrdered: json['last_ordered'] != null
          ? DateTime.parse(json['last_ordered'].toString())
          : null,
      lastViewed: json['last_viewed'] != null
          ? DateTime.parse(json['last_viewed'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      sodas: json['sodas'] ?? 0,
      supplements: List<String>.from(json['supplements'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      nutritionalInfo: json['nutritionalInfo'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
      isVegetarian: json['isVegetarian'] ?? false,
      isVegan: json['isVegan'] ?? false,
      isGlutenFree: json['isGlutenFree'] ?? false,
      isSpicy: json['isSpicy'] ?? false,
      calories: json['calories'] ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
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
      'categorie': category,
      'preparation_time': preparationTime,
      'isAvailable': isAvailable,
      'rating': rating,
      'rating_count': ratingCount,
      'order_count': orderCount,
      'view_count': viewCount,
      'popularity_score': popularityScore,
      'last_ordered': lastOrdered?.toIso8601String(),
      'last_viewed': lastViewed?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sodas': sodas,
      'supplements': supplements,
      'allergens': allergens,
      'nutritionalInfo': nutritionalInfo,
      'tags': tags,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isSpicy': isSpicy,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  // Constructeur pour Firestore
  factory DishModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return DishModel(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toString() ?? '0',
      imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
      restaurantId: data['restaurant_id'] ?? data['restaurantId'] ?? '',
      description: data['description'] ?? '',
      category: data['categorie'] ?? data['category'] ?? '',
      preparationTime:
          data['preparation_time'] ?? data['preparationTime'] ?? '',
      isAvailable: data['isAvailable'] ?? data['is_available'] ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['rating_count'] ?? data['ratingCount'] ?? 0,
      orderCount: data['order_count'] ?? data['orderCount'] ?? 0,
      viewCount: data['view_count'] ?? data['viewCount'] ?? 0,
      popularityScore: (data['popularity_score'] as num?)?.toDouble() ?? 0.0,
      lastOrdered: data['last_ordered'] != null
          ? (data['last_ordered'] as Timestamp).toDate()
          : null,
      lastViewed: data['last_viewed'] != null
          ? (data['last_viewed'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      sodas: data['sodas'] ?? 0,
      supplements: List<String>.from(data['supplements'] ?? []),
      allergens: List<String>.from(data['allergens'] ?? []),
      nutritionalInfo: data['nutritionalInfo'] ?? {},
      tags: List<String>.from(data['tags'] ?? []),
      isVegetarian: data['isVegetarian'] ?? false,
      isVegan: data['isVegan'] ?? false,
      isGlutenFree: data['isGlutenFree'] ?? false,
      isSpicy: data['isSpicy'] ?? false,
      calories: data['calories'] ?? 0,
      protein: (data['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (data['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (data['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
