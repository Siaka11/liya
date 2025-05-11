

class Restaurant {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String country;
  final String? phone;
  final String? email;
  final String? latitude;
  final String? longitude;
/*  final Map<String, dynamic>? openingHours;
  final String? coverImage;
  final bool isActive;
  final DateTime createdAt;*/

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.country = 'Côte d\'ivoire',
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
/*    this.openingHours,
    this.coverImage,
    this.isActive = true,
    required this.createdAt,*/
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      country: json['country'] ?? 'Côte d\'ivoire',
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude'],
      longitude: json['longitude'],
/*      openingHours: json['opening_hours'] != null ? Map<String, dynamic>.from(json['opening_hours']) : null,
      coverImage: json['cover_image'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),*/
    );
  }
}