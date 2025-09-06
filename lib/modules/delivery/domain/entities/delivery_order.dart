enum DeliveryStatus {
  reception, // Commande reçue, en attente d'assignation
  assigned, // Commande assignée à un livreur
  enRoute, // En cours de livraison
  livre, // Livraison terminée avec succès
  nonLivre, // Livraison échouée/annulée
}

enum DeliveryType {
  restaurant,
  parcel,
}

class DeliveryOrder {
  final String id;
  final String customerPhoneNumber;
  final String customerName;
  final String customerAddress;
  final String? deliveryPhoneNumber; // Livreur assigné
  final String? deliveryName; // Nom du livreur
  final DeliveryType type;
  final DeliveryStatus status;
  final double amount;
  final double deliveryFee;
  final String description;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String? notes;
  final double? rating;
  final String? ratingComment;
  final double? destinationLatitude; // Coordonnées de destination
  final double? destinationLongitude; // Coordonnées de destination
  // Informations complètes du client
  final String? customerEmail;
  final String? customerFullName;

  const DeliveryOrder({
    required this.id,
    required this.customerPhoneNumber,
    required this.customerName,
    required this.customerAddress,
    this.deliveryPhoneNumber,
    this.deliveryName,
    required this.type,
    required this.status,
    required this.amount,
    required this.deliveryFee,
    required this.description,
    required this.createdAt,
    this.assignedAt,
    this.completedAt,
    this.notes,
    this.rating,
    this.ratingComment,
    this.destinationLatitude,
    this.destinationLongitude,
    this.customerEmail,
    this.customerFullName,
  });

  DeliveryOrder copyWith({
    String? id,
    String? customerPhoneNumber,
    String? customerName,
    String? customerAddress,
    String? deliveryPhoneNumber,
    String? deliveryName,
    DeliveryType? type,
    DeliveryStatus? status,
    double? amount,
    double? deliveryFee,
    String? description,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? notes,
    double? rating,
    String? ratingComment,
    double? destinationLatitude,
    double? destinationLongitude,
    String? customerEmail,
    String? customerFullName,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      deliveryPhoneNumber: deliveryPhoneNumber ?? this.deliveryPhoneNumber,
      deliveryName: deliveryName ?? this.deliveryName,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      customerEmail: customerEmail ?? this.customerEmail,
      customerFullName: customerFullName ?? this.customerFullName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_phone_number': customerPhoneNumber,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'delivery_phone_number': deliveryPhoneNumber,
      'delivery_name': deliveryName,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'delivery_fee': deliveryFee,
      'description': description,
      'created_at': createdAt,
      'assigned_at': assignedAt,
      'completed_at': completedAt,
      'notes': notes,
      'rating': rating,
      'rating_comment': ratingComment,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'customer_email': customerEmail,
      'customer_full_name': customerFullName,
    };
  }

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'] ?? '',
      customerPhoneNumber: map['customer_phone_number'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerAddress: map['customer_address'] ?? '',
      deliveryPhoneNumber: map['delivery_phone_number'],
      deliveryName: map['delivery_name'],
      type: DeliveryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DeliveryType.restaurant,
      ),
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DeliveryStatus.reception,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      deliveryFee: (map['delivery_fee'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      createdAt:
          map['created_at'] is DateTime ? map['created_at'] : DateTime.now(),
      assignedAt: map['assigned_at'],
      completedAt: map['completed_at'],
      notes: map['notes'],
      rating: map['rating']?.toDouble(),
      ratingComment: map['rating_comment'],
      destinationLatitude: map['destination_latitude']?.toDouble(),
      destinationLongitude: map['destination_longitude']?.toDouble(),
      customerEmail: map['customer_email'],
      customerFullName: map['customer_full_name'],
    );
  }

  double get totalAmount => amount + deliveryFee;
  bool get isAssigned => deliveryPhoneNumber != null;
  bool get isCompleted => status == DeliveryStatus.livre;
  bool get isPending => status == DeliveryStatus.reception;
  bool get isInProgress => status == DeliveryStatus.enRoute;
  bool get isFailed => status == DeliveryStatus.nonLivre;
}
