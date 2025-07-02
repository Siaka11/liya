class DeliveryUser {
  final String id; // phoneNumber
  final String phoneNumber;
  final String name;
  final String lastname;
  final String email;
  final String address;
  final String phone;
  final DateTime createdAt;
  final String role;
  final bool isAvailable;
  final double totalEarnings;
  final int completedDeliveries;
  final double rating;
  final int totalRatings;

  const DeliveryUser({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.lastname,
    required this.email,
    required this.address,
    required this.phone,
    required this.createdAt,
    required this.role,
    this.isAvailable = false,
    this.totalEarnings = 0.0,
    this.completedDeliveries = 0,
    this.rating = 0.0,
    this.totalRatings = 0,
  });

  DeliveryUser copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? lastname,
    String? email,
    String? address,
    String? phone,
    DateTime? createdAt,
    String? role,
    bool? isAvailable,
    double? totalEarnings,
    int? completedDeliveries,
    double? rating,
    int? totalRatings,
  }) {
    return DeliveryUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      isAvailable: isAvailable ?? this.isAvailable,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'lastname': lastname,
      'email': email,
      'address': address,
      'phone': phone,
      'created_at': createdAt,
      'role': role,
      'active': isAvailable,
      'total_earnings': totalEarnings,
      'completed_deliveries': completedDeliveries,
      'rating': rating,
      'total_ratings': totalRatings,
    };
  }

  factory DeliveryUser.fromMap(Map<String, dynamic> map) {
    return DeliveryUser(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone_number'] ?? '',
      name: map['name'] ?? '',
      lastname: map['lastname'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      createdAt:
          map['created_at'] is DateTime ? map['created_at'] : DateTime.now(),
      role: map['role'] ?? '',
      isAvailable: map['active'] ?? false,
      totalEarnings: (map['total_earnings'] ?? 0.0).toDouble(),
      completedDeliveries: map['completed_deliveries'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['total_ratings'] ?? 0,
    );
  }

  String get fullName => '$name $lastname';
  double get averageRating => totalRatings > 0 ? rating / totalRatings : 0.0;
}
