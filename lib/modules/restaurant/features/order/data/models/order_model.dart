import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required String id,
    required String phoneNumber,
    required List<OrderItem> items,
    required double total,
    required double subtotal,
    required int deliveryFee,
    required OrderStatus status,
    required DateTime createdAt,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
    double? distance,
    int? deliveryTime,
    String? address,
  }) : super(
          id: id,
          phoneNumber: phoneNumber,
          items: items,
          total: total,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          status: status,
          createdAt: createdAt,
          latitude: latitude,
          longitude: longitude,
          deliveryInstructions: deliveryInstructions,
          distance: distance,
          deliveryTime: deliveryTime,
          address: address,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      total: (json['total'] as num).toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      status: _statusFromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      deliveryInstructions: json['deliveryInstructions'],
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      deliveryTime: json['deliveryTime'] as int?,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'items': items.map((e) {
        if (e is OrderItemModel) {
          return e.toJson();
        } else {
          return OrderItemModel(
            name: e.name,
            quantity: e.quantity,
            price: e.price,
          ).toJson();
        }
      }).toList(),
      'total': total,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'deliveryInstructions': deliveryInstructions,
      'distance': distance,
      'deliveryTime': deliveryTime,
      'address': address,
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'reception':
        return OrderStatus.reception;
      case 'enRoute':
        return OrderStatus.enRoute;
      case 'livre':
        return OrderStatus.livre;
      case 'nonLivre':
        return OrderStatus.nonLivre;
      default:
        return OrderStatus.reception;
    }
  }
}

class OrderItemModel extends OrderItem {
  OrderItemModel({
    required String name,
    required int quantity,
    required double price,
  }) : super(name: name, quantity: quantity, price: price);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
