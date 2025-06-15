import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrders {
  final OrderRepository repository;
  GetOrders(this.repository);

  Future<List<Order>> call(String phoneNumber) {
    return repository.getOrders(phoneNumber);
  }
}
