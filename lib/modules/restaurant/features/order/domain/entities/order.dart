enum OrderStatus { reception, enRoute, livre, nonLivre }

class Order {
  final String id;
  final String phoneNumber;
  final String? phone;
  final List<OrderItem> items;
  final double total;
  final double subtotal;
  final int deliveryFee;
  final OrderStatus status;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;
  final double? distance;
  final int? deliveryTime;
  final String? address;

  Order({
    required this.id,
    required this.phoneNumber,
    this.phone,
    required this.items,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
    this.distance,
    this.deliveryTime,
    this.address,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
