import '../../domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  SearchResultModel({
    required int id,
    required String name,
    required String imageUrl,
    required double price,
    required String description,
    required String restaurantId,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          price: price,
          description: description,
          restaurantId: restaurantId,
        );

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price:
          double.tryParse(json['price'].toString().replaceAll(',', '.')) ?? 0.0,
      description: json['description'] ?? '',
      restaurantId: json['restaurant_id'] ?? '',
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
    };
  }
}
