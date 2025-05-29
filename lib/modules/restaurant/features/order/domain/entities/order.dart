enum OrderStatus { reception, enRoute, livre, nonLivre }

class Order {
  final String id;
  final String phoneNumber;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? deliveryInstructions;

  Order({
    required this.id,
    required this.phoneNumber,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.deliveryInstructions,
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
