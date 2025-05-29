import '../entities/order.dart';

abstract class OrderRepository {
  Future<void> createOrder(Order order);
  Future<List<Order>> getOrders(String phoneNumber);
  Future<Order?> getOrderById(String id);
}
