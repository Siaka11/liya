import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required String id,
    required String name,
    required String email,
    String? phoneNumber,
    required String address,
    required List<String> paymentMethods,
    required List<Order> orders,
    required phone,
  }) : super(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          address: address,
          paymentMethods: paymentMethods,
          orders: orders,
          phone: phone,
        );

  factory UserProfileModel.fromFirestore(Map<String, dynamic> data, String id) {
    final List<dynamic> ordersData = data['orders'] as List<dynamic>? ?? [];
    final List<Order> orders = ordersData
        .map((orderData) => Order(
              id: orderData['id'] ?? '',
              restaurantName: orderData['restaurantName'] ?? '',
              orderDate: (orderData['orderDate'] as Timestamp).toDate(),
              total: (orderData['total'] ?? 0).toDouble(),
              status: orderData['status'] ?? '',
              items: (orderData['items'] as List<dynamic>? ?? [])
                  .map((itemData) => OrderItem(
                        name: itemData['name'] ?? '',
                        quantity: itemData['quantity'] ?? 0,
                        price: (itemData['price'] ?? 0).toDouble(),
                      ))
                  .toList(),
            ))
        .toList();

    return UserProfileModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'] ?? '',
      paymentMethods: List<String>.from(data['paymentMethods'] ?? []),
      orders: orders,
      phone: data['phone'] ?? '',
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      address: json['address'] ?? '',
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      orders: [],
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'paymentMethods': paymentMethods,
      'phone': phone,
      'orders': orders
          .map((order) => {
                'id': order.id,
                'restaurantName': order.restaurantName,
                'orderDate': Timestamp.fromDate(order.orderDate),
                'total': order.total,
                'status': order.status,
                'items': order.items
                    .map((item) => {
                          'name': item.name,
                          'quantity': item.quantity,
                          'price': item.price,
                        })
                    .toList(),
              })
          .toList(),
    };
  }
}
