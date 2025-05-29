import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import '../../data/models/order_model.dart';

final orderRepositoryProvider = Provider((ref) {
  final dataSource =
      OrderRemoteDataSourceImpl(firestore: cf.FirebaseFirestore.instance);
  return OrderRepositoryImpl(dataSource);
});

final orderStreamProvider =
    StreamProvider.family<Order, String>((ref, orderId) async* {
  final repo = ref.watch(orderRepositoryProvider);
  // Ici, on suppose que tu as une méthode watchOrderById qui retourne un Stream<Order>
  // Si ce n'est pas le cas, il faut l'ajouter dans OrderRepositoryImpl
  await for (final order in repo.watchOrderById(orderId)) {
    yield order;
  }
});

final orderListStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, phoneNumber) async* {
  final repo = ref.watch(orderRepositoryProvider);
  final firestore =
      (repo.remoteDataSource as OrderRemoteDataSourceImpl).firestoreInstance;
  await for (final snap in firestore
      .collection('orders')
      .where('phoneNumber', isEqualTo: phoneNumber)
      .orderBy('createdAt', descending: true)
      .snapshots()) {
    final orders = snap.docs
        .map((doc) => OrderModel.fromJson(doc.data()) as Order)
        .toList();
    yield orders;
  }
});
