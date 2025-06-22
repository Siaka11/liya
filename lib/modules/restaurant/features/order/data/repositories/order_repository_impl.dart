import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createOrder(Order order) async {
    // Génération d'un ID unique au format RESTOyyyyMMddXXXXX
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    // Pour la démo, on utilise un timestamp pour l'unicité
    final unique = DateTime.now().millisecondsSinceEpoch % 100000;
    final orderId = 'RESTO${dateStr}${unique.toString().padLeft(5, '0')}';
    final orderWithId = Order(
      id: orderId,
      phoneNumber: order.phoneNumber,
      items: order.items,
      total: order.total,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      status: order.status,
      createdAt: order.createdAt,
      latitude: order.latitude,
      longitude: order.longitude,
      deliveryInstructions: order.deliveryInstructions,
      distance: order.distance,
      deliveryTime: order.deliveryTime,
      address: order.address,
    );
    return remoteDataSource.createOrder(OrderModel(
      id: orderWithId.id,
      phoneNumber: orderWithId.phoneNumber,
      items: orderWithId.items,
      total: orderWithId.total,
      subtotal: orderWithId.subtotal,
      deliveryFee: orderWithId.deliveryFee,
      status: orderWithId.status,
      createdAt: orderWithId.createdAt,
      latitude: orderWithId.latitude,
      longitude: orderWithId.longitude,
      deliveryInstructions: orderWithId.deliveryInstructions,
      distance: orderWithId.distance,
      deliveryTime: orderWithId.deliveryTime,
      address: orderWithId.address,
    ));
  }

  @override
  Future<List<Order>> getOrders(String phoneNumber) async {
    final models = await remoteDataSource.getOrders(phoneNumber);
    return models;
  }

  @override
  Future<Order?> getOrderById(String id) async {
    return await remoteDataSource.getOrderById(id);
  }

  // Ajout : stream pour Riverpod
  Stream<Order> watchOrderById(String id) async* {
    // Firestore snapshot
    final ds = remoteDataSource as OrderRemoteDataSourceImpl;
    final docRef = ds.firestoreInstance.collection('orders').doc(id);
    await for (final snap in docRef.snapshots()) {
      if (snap.exists && snap.data() != null) {
        yield OrderModel.fromJson(snap.data()!);
      }
    }
  }
}
