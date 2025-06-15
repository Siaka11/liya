import 'package:dartz/dartz.dart';
import 'package:liya/core/failure.dart';
import '../entities/delivery_info.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, void>> saveDeliveryInfo(
      String userId, DeliveryInfo deliveryInfo);
  Future<Either<Failure, DeliveryInfo>> getDeliveryInfo(String userId);
  Future<Either<Failure, void>> placeOrder(String userId);
}
