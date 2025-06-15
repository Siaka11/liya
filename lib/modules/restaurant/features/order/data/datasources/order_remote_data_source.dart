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
    await firestore.collection('orders').doc(order.id).set(order.toJson());
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
