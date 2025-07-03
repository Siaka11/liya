import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<void> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders(String phoneNumber);
  Future<OrderModel?> getOrderById(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore firestore;
  OrderRemoteDataSourceImpl({required this.firestore});

  FirebaseFirestore get firestoreInstance => firestore;

  @override
  Future<void> createOrder(OrderModel order) async {
    print('DEBUG - createOrder called with phone: ${order.phone}');

    final orderData = order.toJson();
    print('DEBUG - orderData after toJson: ${orderData['phone']}');

    // S'assurer que le champ phone est toujours présent dans Firestore
    if (!orderData.containsKey('phone')) {
      orderData['phone'] = order.phone;
      print('DEBUG - Added phone to orderData: ${orderData['phone']}');
    }

    print('DEBUG - Final orderData phone: ${orderData['phone']}');
    print('DEBUG - Saving to Firestore: $orderData');

    await firestore.collection('orders').doc(order.id).set(orderData);
  }

  @override
  Future<List<OrderModel>> getOrders(String phoneNumber) async {
    final query = await firestore
        .collection('orders')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await firestore.collection('orders').doc(id).get();
    if (doc.exists) {
      return OrderModel.fromJson(doc.data()!);
    }
    return null;
  }
}
