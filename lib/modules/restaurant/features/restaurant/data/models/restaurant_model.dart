import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String image;
  final String address;
  final double rating;
  final String cuisine;
  final bool isOpen;
  final List<String> categories;
  final Map<String, dynamic> location;
  final String phoneNumber;
  final String description;
  final List<String> photos;
  final Map<String, dynamic> openingHours;
  final double deliveryFee;
  final int deliveryTime;
  final double minimumOrder;
  final bool isFeatured;
  final bool isPromoted;
  final Map<String, dynamic>? promotion;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.rating,
    required this.cuisine,
    required this.isOpen,
    required this.categories,
    required this.location,
    required this.phoneNumber,
    required this.description,
    required this.photos,
    required this.openingHours,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.minimumOrder,
    required this.isFeatured,
    required this.isPromoted,
    this.promotion,
  });

  factory RestaurantModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RestaurantModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      address: data['address'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      cuisine: data['cuisine'] ?? '',
      isOpen: data['isOpen'] ?? false,
      categories: List<String>.from(data['categories'] ?? []),
      location: data['location'] ?? {},
      phoneNumber: data['phoneNumber'] ?? '',
      description: data['description'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      openingHours: data['openingHours'] ?? {},
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      deliveryTime: data['deliveryTime'] ?? 0,
      minimumOrder: (data['minimumOrder'] ?? 0.0).toDouble(),
      isFeatured: data['isFeatured'] ?? false,
      isPromoted: data['isPromoted'] ?? false,
      promotion: data['promotion'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'image': image,
      'address': address,
      'rating': rating,
      'cuisine': cuisine,
      'isOpen': isOpen,
      'categories': categories,
      'location': location,
      'phoneNumber': phoneNumber,
      'description': description,
      'photos': photos,
      'openingHours': openingHours,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'minimumOrder': minimumOrder,
      'isFeatured': isFeatured,
      'isPromoted': isPromoted,
      'promotion': promotion,
    };
  }
}
