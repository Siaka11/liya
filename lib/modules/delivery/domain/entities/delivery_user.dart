import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryUser {
  final String id; // phoneNumber
  final String phoneNumber;
  final String name;
  final String lastname;
  final String email;
  final String address;
  final String role;
  final DateTime? createdAt;
  final bool
      active; // Changé de isAvailable à active pour correspondre à Firestore
  final double totalEarnings;
  final int completedDeliveries;
  final double rating;
  final int totalRatings;
  // Nouveaux champs pour la gestion de position
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  final bool isOnline;
  final String? currentOrderId; // Commande en cours

  const DeliveryUser({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.lastname,
    required this.email,
    required this.address,
    required this.role,
    this.createdAt,
    this.active = false, // Changé de isAvailable à active
    this.totalEarnings = 0.0,
    this.completedDeliveries = 0,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    this.isOnline = false,
    this.currentOrderId,
  });

  DeliveryUser copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? lastname,
    String? email,
    String? address,
    String? role,
    DateTime? createdAt,
    bool? active, // Changé de isAvailable à active
    double? totalEarnings,
    int? completedDeliveries,
    double? rating,
    int? totalRatings,
    double? currentLatitude,
    double? currentLongitude,
    DateTime? lastLocationUpdate,
    bool? isOnline,
    String? currentOrderId,
  }) {
    return DeliveryUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active, // Changé de isAvailable à active
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      isOnline: isOnline ?? this.isOnline,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'lastname': lastname,
      'email': email,
      'address': address,
      'role': role,
      'created_at': createdAt,
      'active': active, // Utiliser 'active' pour correspondre à Firestore
      'total_earnings': totalEarnings,
      'completed_deliveries': completedDeliveries,
      'rating': rating,
      'total_ratings': totalRatings,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'last_location_update': lastLocationUpdate,
      'is_online': isOnline,
      'current_order_id': currentOrderId,
    };
  }

  factory DeliveryUser.fromMap(Map<String, dynamic> map) {
    return DeliveryUser(
      id: map['id'] ?? map['phoneNumber'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
      name: map['name'] ?? '',
      lastname: map['lastname'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? '',
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : null,
      active:
          map['active'] ?? false, // Utiliser 'active' au lieu de 'isAvailable'
      completedDeliveries: map['completed_deliveries']?.toInt() ?? 0,
      totalEarnings: map['total_earnings']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings']?.toInt() ?? 0,
      currentLatitude: map['current_latitude']?.toDouble(),
      currentLongitude: map['current_longitude']?.toDouble(),
      lastLocationUpdate: map['last_location_update'] is Timestamp
          ? (map['last_location_update'] as Timestamp).toDate()
          : null,
      isOnline: map['is_online'] ?? false,
      currentOrderId: map['current_order_id'],
    );
  }

  String get fullName => '$name $lastname';
  double get averageRating => totalRatings > 0 ? rating / totalRatings : 0.0;
}
