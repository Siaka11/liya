class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<String> addresses;
  final List<String> paymentMethods;
  final List<Order> orders;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.addresses,
    required this.paymentMethods,
    required this.orders,
  });
}

class Order {
  final String id;
  final String restaurantName;
  final DateTime orderDate;
  final double total;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.restaurantName,
    required this.orderDate,
    required this.total,
    required this.status,
    required this.items,
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
