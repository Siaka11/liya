import '../../domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  SearchResultModel({
    required String id,
    required String name,
    required String imageUrl,
    required double price,
    required String description,
    required String restaurantId,
    required String type,
    required String category,
    required String restaurantName,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          price: price,
          description: description,
          restaurantId: restaurantId,
          type: type,
          category: category,
          restaurantName: restaurantName,
        );

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      price:
          double.tryParse(json['price'].toString().replaceAll(',', '.')) ?? 0.0,
      description: json['description'] ?? '',
      restaurantId: json['restaurantId'] ?? json['restaurant_id'] ?? '',
      type: json['type'] ?? 'dish',
      category: json['category'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'restaurantId': restaurantId,
      'type': type,
      'category': category,
      'restaurantName': restaurantName,
    };
  }

  // Constructeur pour Firestore
  factory SearchResultModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return SearchResultModel(
      id: documentId,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      type: data['type'] ?? 'dish',
      category: data['category'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
    );
  }
}
